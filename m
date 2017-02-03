From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net 2/2] macvtap: read vnet_hdr_size once
Date: Fri, 03 Feb 2017 15:27:49 -0800
Message-ID: <1486164469.21871.123.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170203232049.38982-1-willemdebruijn.kernel@gmail.com>
         <20170203232049.38982-3-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        Willem de Bruijn <willemb@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:33517 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752873AbdBCX1u (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 18:27:50 -0500
Received: by mail-pg0-f66.google.com with SMTP id 194so3112405pgd.0
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2017 15:27:50 -0800 (PST)
In-Reply-To: <20170203232049.38982-3-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-02-03 at 18:20 -0500, Willem de Bruijn wrote:
> From: Willem de Bruijn <willemb@google.com>
> 
> When IFF_VNET_HDR is enabled, a virtio_net header must precede data.
> Data length is verified to be greater than or equal to expected header
> length tun->vnet_hdr_sz before copying.
> 
> Macvtap functions read the value once, but unless READ_ONCE is used,
> the compiler may ignore this and read multiple times. Enforce a single
> read and locally cached value to avoid updates between test and use.
> 
> Signed-off-by: Willem de Bruijn <willemb@google.com>
> Suggested-by: Eric Dumazet <edumazet@google.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
