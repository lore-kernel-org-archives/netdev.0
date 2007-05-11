From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [stable] [PATCH 2.6.21-stable] [IPV6]: Restore semantics of
 Routing Header processing.
Date: Sat, 12 May 2007 01:28:20 +0900 (JST)
Message-ID: <20070512.012820.126195303.yoshfuji@linux-ipv6.org>
References: <20070512.011728.16743460.yoshfuji@linux-ipv6.org>
	<20070511162243.GC3516@sequoia.sous-sol.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@kernel.org
To: chrisw@sous-sol.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:37589 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759508AbXEKQ2H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2007 12:28:07 -0400
In-Reply-To: <20070511162243.GC3516@sequoia.sous-sol.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20070511162243.GC3516@sequoia.sous-sol.org> (at Fri, 11 May 2007 09:22:43 -0700), Chris Wright <chrisw@sous-sol.org> says:

> * YOSHIFUJI Hideaki / 吉藤英明 (yoshfuji@linux-ipv6.org) wrote:
> > The "fix" for emerging security threats was overkill and it broke
> > basic semantic of IPv6 routing header processing.  We should assume
> > RT0 (or even RT2, depends on configuration) as "unknown" RH type so
> > that we
> > - silently ignore the routing header if segleft == 0
> > - or, send ICMPv6 Parameter Problem message back to the sender,
> >   otherwise.
> 
> Does that mean this one has received testing and is good for -stable
> now, or does it need some bake time?

Chris, I think it is okay, but
please wait for Dave's approval.
Thanks.

--yoshfuji
