From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 13/13] [RFC] [IPV6] Fix source prefix routing problems
 when source address undefined.
Date: Tue, 17 Oct 2006 21:17:30 +0900 (JST)
Message-ID: <20061017.211730.51920084.yoshfuji@linux-ipv6.org>
References: <20061017101402.GM12964@postel.suug.ch>
	<20061017.200005.70903049.yoshfuji@linux-ipv6.org>
	<20061017113511.GN12964@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vnuorval@tcs.hut.fi, davem@davemloft.net, kim.nordlund@nokia.com,
	netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:46861 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S1750729AbWJQMO6
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Oct 2006 08:14:58 -0400
To: tgraf@suug.ch
In-Reply-To: <20061017113511.GN12964@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20061017113511.GN12964@postel.suug.ch> (at Tue, 17 Oct 2006 13:35:11 +0200), Thomas Graf <tgraf@suug.ch> says:

:
> different logic. In order to solve this, rules must be restricted to
> one of these paths, i.e. a rule intending to make certain prefixes
> unreachable may not apply to the source selection logic. This can be
> achieved using the 'reason' field I proposed in my netconf slides, it
> would allow turning the first rule example into
> 
> 	rule add from 2001::1/128 for INPUT unreachable
> 
> which would no longer apply when looking up the source address or
> deciding the outgoing route.

And/or, to take into account input interface, we could do
	rule add from 2001::1/128 in eth0 unreachable
maybe.

--yoshfuji


