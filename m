From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 9/9] [NET]: Move netlink interface bits to linux/if.h
Date: Mon, 7 Aug 2006 10:57:23 -0700
Message-ID: <20060807105723.29d2fd72@dxpl.pdx.osdl.net>
References: <20060805003452.493542515@postel.suug.ch>
	<20060805003538.106022871@postel.suug.ch>
	<44D5813A.1070309@osdl.org>
	<20060804.232314.105406244.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:12433 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750826AbWHGR50 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2006 13:57:26 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060804.232314.105406244.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 04 Aug 2006 23:23:14 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@osdl.org>
> Date: Sat, 05 Aug 2006 22:42:18 -0700
> 
> > Thomas Graf wrote:
> > > -/* The struct should be in sync with struct net_device_stats */
> > > -struct rtnl_link_stats
> > > -{
> > > -	__u32	rx_packets;		/* total packets received	*/
> > > -	__u32	tx_packets;		/* total packets transmitted	*/
> > > -	__u32	rx_bytes;		/* total bytes received 	*/
> > > -	__u32	tx_bytes;		/* total bytes transmitted	*/
> > >   
> > 
> > Make the packets and byte counts __u64 so if/when we extend net_device 
> > stats to bigger
> > values, the message format doesn't have to change.
> 
> It's an existing ABI that he is just moving from one place
> to another, we are not at liberty to change it's layout.

Yeah that makes sense, I thought it was a new interface.

-- 
Stephen Hemminger <shemminger@osdl.org>
"And in the Packet there writ down that doome"
