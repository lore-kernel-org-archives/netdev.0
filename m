From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/5] net: Fix GRE RX to use
 skb_transport_header for GRE header offset
Date: Mon, 08 Sep 2014 03:37:00 -0700
Message-ID: <1410172620.11872.88.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1410153989-23837-1-git-send-email-therbert@google.com>
	 <1410153989-23837-2-git-send-email-therbert@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:40233 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753172AbaIHKhD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2014 06:37:03 -0400
Received: by mail-pd0-f172.google.com with SMTP id v10so7532909pde.17
        for <netdev@vger.kernel.org>; Mon, 08 Sep 2014 03:37:02 -0700 (PDT)
In-Reply-To: <1410153989-23837-2-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-09-07 at 22:26 -0700, Tom Herbert wrote:
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

Acked-by: Eric Dumazet <edumazet@google.com>

Note this has nothing to do with GRO ;)
