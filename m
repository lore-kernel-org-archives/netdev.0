From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHSET] Multiple IPV6 Routing Tables & Policy Routing
Date: Fri, 04 Aug 2006 03:40:43 -0700 (PDT)
Message-ID: <20060804.034043.41657264.davem@davemloft.net>
References: <20060804102308.711837665@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vnuorval@tcs.hut.fi,
	usagi-core@linux-ipv6.org, yoshfuji@linux-ipv6.org,
	anttit@tcs.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:29903
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1161164AbWHDKki (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Aug 2006 06:40:38 -0400
To: tgraf@suug.ch
In-Reply-To: <20060804102308.711837665@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Fri, 04 Aug 2006 12:23:08 +0200

> This patchset implements multiple IPv6 routing tables and
> policy routing. Even though the code is almost rewritten
> entirely the work is based on the MIPL patch found on
> mobile-ipv6.org which is being jointly developed by Helsinki
> University of Technology (HUT) and the USAGI/WIDE Project.
> 
> Reference counting on routing tables was removed to decrease
> the number of required atomic operations during route lookup.
> 
> The tables are now organized in a hashtable to prepare for
> the change in supporting more than 255 tables.
> 
> Matching sources address in policy rules is no longer dependant
> on CONFIG_SUBTREES.

All patches added to net-2.6.19, thanks a lot Thomas.

Please submit any further improvements and bug fixes relative
to these changes, thanks a lot.
