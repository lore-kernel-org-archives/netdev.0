From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net v2 1/3] net/packet: fix overflow in check for priv
 area size
Date: Wed, 29 Mar 2017 08:50:49 -0700
Message-ID: <1490802649.24891.31.camel@edumazet-glaptop3.roam.corp.google.com>
References: <cover.1490796500.git.andreyknvl@google.com>
         <56da2aa1dec51c258eb25693ed87e4de72413463.1490796500.git.andreyknvl@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Willem de Bruijn <willemb@google.com>,
        Craig Gallek <cgallek@google.com>, netdev@vger.kernel.org,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>
To: Andrey Konovalov <andreyknvl@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:36167 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753099AbdC2Pu5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 11:50:57 -0400
Received: by mail-pg0-f68.google.com with SMTP id 81so3150837pgh.3
        for <netdev@vger.kernel.org>; Wed, 29 Mar 2017 08:50:51 -0700 (PDT)
In-Reply-To: <56da2aa1dec51c258eb25693ed87e4de72413463.1490796500.git.andreyknvl@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-03-29 at 16:11 +0200, Andrey Konovalov wrote:
> Subtracting tp_sizeof_priv from tp_block_size and casting to int
> to check whether one is less then the other doesn't always work
> (both of them are unsigned ints).
> 
> Compare them as is instead.
> 
> Also cast tp_sizeof_priv to u64 before using BLK_PLUS_PRIV, as
> it can overflow inside BLK_PLUS_PRIV otherwise.
> 
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
