From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Fix GRE RX to use skb_transport_header for GRE
 header offset
Date: Mon, 08 Sep 2014 08:50:44 -0700
Message-ID: <1410191444.11872.113.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1410190152-7396-1-git-send-email-therbert@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:54760 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752986AbaIHPur (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2014 11:50:47 -0400
Received: by mail-pd0-f171.google.com with SMTP id p10so4052197pdj.16
        for <netdev@vger.kernel.org>; Mon, 08 Sep 2014 08:50:46 -0700 (PDT)
In-Reply-To: <1410190152-7396-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-09-08 at 08:29 -0700, Tom Herbert wrote:
> GRE assumes that the GRE header is at skb_network_header +
> ip_hrdlen(skb). It is more general to use skb_transport_header
> and this allows the possbility of inserting additional header
> between IP and GRE (which is what we will done in Generic UDP
> Encapsulation for GRE).
> 
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  net/ipv4/gre_demux.c | 5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)

I am always confused why you do not include prior Acked-by when you
repost same patch.

This forces me to add it again.

Note this should be a net-next patch, right ?

Acked-by: Eric Dumazet <edumazet@google.com>
