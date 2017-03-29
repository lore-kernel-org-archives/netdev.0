From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net v2 3/3] net/packet: fix overflow in check for
 tp_reserve
Date: Wed, 29 Mar 2017 08:51:31 -0700
Message-ID: <1490802691.24891.33.camel@edumazet-glaptop3.roam.corp.google.com>
References: <cover.1490796500.git.andreyknvl@google.com>
         <b6e7f64aa4f58db0c879510e86196534e472f857.1490796500.git.andreyknvl@google.com>
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
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34318 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752703AbdC2Pve (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 11:51:34 -0400
Received: by mail-pf0-f196.google.com with SMTP id o126so2327804pfb.1
        for <netdev@vger.kernel.org>; Wed, 29 Mar 2017 08:51:33 -0700 (PDT)
In-Reply-To: <b6e7f64aa4f58db0c879510e86196534e472f857.1490796500.git.andreyknvl@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-03-29 at 16:11 +0200, Andrey Konovalov wrote:
> When calculating po->tp_hdrlen + po->tp_reserve the result can overflow.
> 
> Fix by checking that tp_reserve <= INT_MAX on assign.
> 
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks !
