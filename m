From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [net-2.6.22] [IPV4]: Fix build without procfs.
Date: Wed, 25 Apr 2007 11:46:50 +0900 (JST)
Message-ID: <20070425.114650.93714393.yoshfuji@linux-ipv6.org>
References: <20070425.002048.109830535.yoshfuji@linux-ipv6.org>
	<E1HgXMD-0000LK-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:32960 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161829AbXDYCqx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2007 22:46:53 -0400
In-Reply-To: <E1HgXMD-0000LK-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

In article <E1HgXMD-0000LK-00@gondolin.me.apana.org.au> (at Wed, 25 Apr 2007 12:35:49 +1000), Herbert Xu <herbert@gondor.apana.org.au> says:

> This makes no sense.  Why should we include all these proc operations
> when PROC_FS is turned off? How about this as a fix (on top of the
> above patch):
> 
> [IPV4]: Move snmp_mib_init out of proc.c
> 
> The function snmp_mib_init has nothing to do with proc so this patch
> moves it out of proc.c and to the only place that uses it.  Right now
> there is only one user so I'ved made it static too.

Herbert, as I said before, we could defer that.
It was preparation for future development (per-interface statistics
and netlink interface.
(I would say, proc.c should be snmp.c.)

Regards,

--yoshfuji
