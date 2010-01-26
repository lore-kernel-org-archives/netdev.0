From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] IPv6: conntrack: Use protocol-related
 initialization routine to initial queues of IPv6 connection track
Date: Tue, 26 Jan 2010 05:11:47 -0800 (PST)
Message-ID: <20100126.051147.256313206.davem@davemloft.net>
References: <20100125.233254.35824860.davem@davemloft.net>
	<4B5EE2C6.6010802@cn.fujitsu.com>
	<4B5EE436.3040204@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shanwei@cn.fujitsu.com, yasuyuki.kozakai@toshiba.co.jp,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4B5EE436.3040204@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Tue, 26 Jan 2010 13:46:46 +0100

> Oops, sorry. Not sure why I missed this, I've successfully
> tested that change multiple times.

This situation is error prone, and I don't blame you for not catching
it, because these common ipv6 fragmentation functions are assuming
things about the layout of the first few struct members of the
container in which the top level data structure lives.

What should happen is that when such an assumption exists, it should
be explicitly codified.

Just like how we embed struct sock_common in both struct socket
and in the TCP time-wait minisockets.

Anyways, meanwhile I'll apply the fix.  And yes I know it needs
to go to stable too... :-)

