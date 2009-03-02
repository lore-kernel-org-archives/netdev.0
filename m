From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] iptables: new strict host model match
Date: Mon, 2 Mar 2009 10:53:10 -0800
Message-ID: <20090302105310.6c247f88@s6510>
References: <20090226175247.5e56910f@nehalam>
	<Pine.LNX.4.64.0903021427570.27363@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:40650 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752341AbZCBSx6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Mar 2009 13:53:58 -0500
In-Reply-To: <Pine.LNX.4.64.0903021427570.27363@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2 Mar 2009 14:42:33 +0100 (CET)
Jesper Dangaard Brouer <hawk@diku.dk> wrote:

> On Thu, 26 Feb 2009, Stephen Hemminger wrote:
> 
> > This is a simple little iptables match that can be used to create the Strong
> > End System model, that router and other non-Linux customers expect. There
> > are management and other applications that use ping and expect to only get
> > a response when the interface with that address is up. Normally, a Linux
> > system will respond to a packet that arrives for any of the system addresses
> > independent of which link it arrives on.
> 
> Is this no almost the same as:
> 
>   echo 1 > /proc/sys/net/ipv4/conf/all/arp_ignore
> 
>

That doesn't work when system already has an ARP entry and link goes down.
