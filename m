From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net v2 2/3] net/packet: fix overflow in check for
 tp_frame_nr
Date: Wed, 29 Mar 2017 08:51:08 -0700
Message-ID: <1490802668.24891.32.camel@edumazet-glaptop3.roam.corp.google.com>
References: <cover.1490796500.git.andreyknvl@google.com>
         <b6e4098bf0d0bccc538e133ce5200432be8c4732.1490796500.git.andreyknvl@google.com>
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
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34014 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752805AbdC2PvL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 11:51:11 -0400
Received: by mail-pg0-f66.google.com with SMTP id o123so3182591pga.1
        for <netdev@vger.kernel.org>; Wed, 29 Mar 2017 08:51:10 -0700 (PDT)
In-Reply-To: <b6e4098bf0d0bccc538e133ce5200432be8c4732.1490796500.git.andreyknvl@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-03-29 at 16:11 +0200, Andrey Konovalov wrote:
> When calculating rb->frames_per_block * req->tp_block_nr the result
> can overflow.
> 
> Add a check that tp_block_size * tp_block_nr <= UINT_MAX.
> 
> Since frames_per_block <= tp_block_size, the expression would
> never overflow.
> 
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
