From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [RFC][PATCH 0/3][XFRM]: Support packet processing error
 statistics.
Date: Wed, 24 Oct 2007 12:59:25 +0900 (JST)
Message-ID: <20071024.125925.86627480.yoshfuji@linux-ipv6.org>
References: <11930334662094-git-send-email-nakam@linux-ipv6.org>
	<1193056091.4422.33.camel@localhost>
	<200710231608.34661.nakam@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, herbert@gondor.apana.org.au, davem@davemloft.net,
	netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: nakam@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:35986 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753615AbXJXD7W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2007 23:59:22 -0400
In-Reply-To: <200710231608.34661.nakam@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <200710231608.34661.nakam@linux-ipv6.org> (at Tue, 23 Oct 2007 16:08:34 +0900), Masahide NAKAMURA <nakam@linux-ipv6.org> says:

> Monday 22 October 2007 21:28, jamal wrote:
> > On Mon, 2007-22-10 at 15:11 +0900, Masahide NAKAMURA wrote:
:
> This point is one of what I want to hear comment.
> My patch uses "XFRM_MIB_XXX" because I found "LINUX_MIB_XXX" definition at
> include/linux/snmp.h for TCP extended statistics at /proc/net/netstat and
> it does not seem to be defined by any RFC specification. Then I feel it is not so bad to
> use _MIB_ for them. Maybe we have another idea to merge them into LINUX_MIB.
> 
> Now we have the following candidates:
> 
> (1) my patch		XFRM_MIB_INHDRERROR
> (2) some extender	XFRM_XXX_INHDRERROR	(XXX is requested)
> (3) not-mib extender	XFRM_NOTMIB_INHDRERROR
> (4) no extender		XFRM_INHDRERROR
> (5) merge linux-mib	LINUX_MIB_XFRMINHDRERROR
> 
> Comments?

I would support (5) or (1).

--yoshfuji
