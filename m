From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/5] [IPV6]: Multiple Routing Tables
Date: Sat, 29 Jul 2006 12:29:57 +0200
Message-ID: <20060729102957.GH14627@postel.suug.ch>
References: <20060726221100.325687073@postel.suug.ch> <20060726221849.495778268@postel.suug.ch> <20060729.131306.80352422.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, vnuorval@tcs.hut.fi,
	usagi-core@linux-ipv6.org, davem@davemloft.net, anttit@tcs.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:2451 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1422736AbWG2K3i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2006 06:29:38 -0400
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20060729.131306.80352422.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* YOSHIFUJI Hideaki / ?$B5HF#1QL@ <yoshfuji@linux-ipv6.org> 2006-07-29 13:13
> Well, one design consideration that I have had for several months
> is performance impact.
> 
> Previously, we directly use address, ifindex etc., not flowi,
> in IPv6 routing code except for ip6_route_output().
> This patch changes them to use flowi.
> I know this should work and it is a good way for abstraction.
> However, initializing flowi for IPv6 is more expensive than
> one for IPv4, and it would result in poor performance (especially
> without CONFIG_IPV6_MULTIPLE_TABLES).

Do you have numbers for this? Personally I'm more worried
about the number of locks needed for a lookup and the
selection.
