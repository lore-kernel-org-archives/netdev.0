From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net 1/2] tun: read vnet_hdr_sz once
Date: Fri, 03 Feb 2017 15:27:04 -0800
Message-ID: <1486164424.21871.122.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170203232049.38982-1-willemdebruijn.kernel@gmail.com>
         <20170203232049.38982-2-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        Willem de Bruijn <willemb@google.com>,
        Eric Dumazet <edumazet@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35798 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753167AbdBCX1G (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 18:27:06 -0500
Received: by mail-pf0-f194.google.com with SMTP id f144so2440774pfa.2
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2017 15:27:06 -0800 (PST)
In-Reply-To: <20170203232049.38982-2-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-02-03 at 18:20 -0500, Willem de Bruijn wrote:
> From: Willem de Bruijn <willemb@google.com>
> 
> When IFF_VNET_HDR is enabled, a virtio_net header must precede data.
> Data length is verified to be greater than or equal to expected header
> length tun->vnet_hdr_sz before copying.
> 
> Read this value once and cache locally, as it can be updated between
> the test and use (TOCTOU).
> 
> Signed-off-by: Willem de Bruijn <willemb@google.com>
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> CC: Eric Dumazet <edumazet@google.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
