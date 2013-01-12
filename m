From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: [RFC PATCH 5/6] firewire net: IPv6 support (RFC3146).
Date: Sat, 12 Jan 2013 18:42:34 +0100
Message-ID: <20130112184234.313f8283@stein>
References: <50F17171.3050105@linux-ipv6.org>
	<20130112162224.10e2aa44@stein>
	<20130112180058.0289baba@stein>
	<50F19A1B.7050200@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	netdev@vger.kernel.org, linux1394-devel@lists.sourceforge.net
To: stephan.gatzka@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from einhorn.in-berlin.de ([192.109.42.8]:32977 "EHLO
	einhorn.in-berlin.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753743Ab3ALRmy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2013 12:42:54 -0500
In-Reply-To: <50F19A1B.7050200@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Jan 12 Stephan Gatzka wrote:
> 
> > Another thing:  As far as I understand, the current code assumes that
> > peers will use the same unicast_FIFO for IPv4 unicast as for IPv6
> > unicast.  This is not necessarily true.  Either firewire-net needs to
> > maintain two lists of peers (one for IPv4, another for IPv6), or it needs
> > to maintain two unicast_FIFOs per peer.
> >
> 
> Thanks for pointing that out. I would go for two unicast_Fifos per peer.

Indeed.  Plus, if we look up an IPv6 peer whose IPv6 unicast_FIFO is as
yet unkown but whose IPv4 unicast_FIFO is already known, we could
optimistically use the latter until we learn the former.  And vice versa.
-- 
Stefan Richter
-=====-===-= ---= -==--
http://arcgraph.de/sr/
