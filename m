From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 9/9] [NET]: Move netlink interface bits to linux/if.h
Date: Fri, 04 Aug 2006 23:23:14 -0700 (PDT)
Message-ID: <20060804.232314.105406244.davem@davemloft.net>
References: <20060805003452.493542515@postel.suug.ch>
	<20060805003538.106022871@postel.suug.ch>
	<44D5813A.1070309@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:17593
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1161520AbWHEGXG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Aug 2006 02:23:06 -0400
To: shemminger@osdl.org
In-Reply-To: <44D5813A.1070309@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Sat, 05 Aug 2006 22:42:18 -0700

> Thomas Graf wrote:
> > -/* The struct should be in sync with struct net_device_stats */
> > -struct rtnl_link_stats
> > -{
> > -	__u32	rx_packets;		/* total packets received	*/
> > -	__u32	tx_packets;		/* total packets transmitted	*/
> > -	__u32	rx_bytes;		/* total bytes received 	*/
> > -	__u32	tx_bytes;		/* total bytes transmitted	*/
> >   
> 
> Make the packets and byte counts __u64 so if/when we extend net_device 
> stats to bigger
> values, the message format doesn't have to change.

It's an existing ABI that he is just moving from one place
to another, we are not at liberty to change it's layout.

We chould create a new one, but that makes no sense until
the device layer actually has the means by which to maintain
u64 values.
