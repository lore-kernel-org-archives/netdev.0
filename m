From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: [PATCH net-next-2.6] dummy: percpu stats and lockless xmit
Date: Tue, 28 Sep 2010 00:52:07 -0700 (PDT)
Message-ID: <636709308.22102.1285660327977.JavaMail.root@tahiti.vyatta.com>
References: <1285656633.10438.35.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:55834 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750974Ab0I1H6g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Sep 2010 03:58:36 -0400
In-Reply-To: <1285656633.10438.35.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> Converts dummy network device driver to :
> 
> - percpu stats
> 
> - 64bit stats
> 
> - lockless xmit (NETIF_F_LLTX)
> 
> - performance features added (NETIF_F_SG | NETIF_F_FRAGLIST |
> NETIF_F_TSO | NETIF_F_NO_CSUM | NETIF_F_HIGHDMA)
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

IFB device could use many of these enhancements.
