From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] [IPV6] remove unused parameter (struct sock parameter)
 from ip6_route_output()
Date: Tue, 18 Mar 2008 18:15:55 +0900 (JST)
Message-ID: <20080318.181555.105003756.yoshfuji@linux-ipv6.org>
References: <eb3ff54b0803180203h18cda4ceja6ae28033638d338@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: ramirose@gmail.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:54283 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751778AbYCRJOh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Mar 2008 05:14:37 -0400
In-Reply-To: <eb3ff54b0803180203h18cda4ceja6ae28033638d338@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NAK; I have a plan to use it in net-2.6.26 tree.

--yoshfuji

In article <eb3ff54b0803180203h18cda4ceja6ae28033638d338@mail.gmail.com> (at Tue, 18 Mar 2008 11:03:04 +0200), "Rami Rosen" <ramirose@gmail.com> says:

> Hi,
> This patch removes the struct sock parameter from ip6_route_output();
> looking at the ip6_route_output() implementation in net/ipv6/route.c
> will show immediately that it is not used in this method.
> 
> In fact, icmp.c and ip6_output.c are the only places in the kernel
> where the sk (struct sock) parameter passed to ip6_route_output() is not NULL;
> anyhow, as explained above, this parameter is unused; changing
> the ip6_route_output() prototype by omitting the struct sock parameter
> does not break anything.
> 
> 
> Regards,
> Rami Rosen
> 
> 
> Signed-off-by: Rami Rosen <ramirose@gmail.com>
