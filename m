From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: [RFC PATCH 5/6] firewire net: IPv6 support (RFC3146).
Date: Sat, 12 Jan 2013 18:00:58 +0100
Message-ID: <20130112180058.0289baba@stein>
References: <50F17171.3050105@linux-ipv6.org>
	<20130112162224.10e2aa44@stein>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Stephan Gatzka <stephan.gatzka@gmail.com>,
	netdev@vger.kernel.org, linux1394-devel@lists.sourceforge.net
To: Stefan Richter <stefanr@s5r6.in-berlin.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from einhorn.in-berlin.de ([192.109.42.8]:60887 "EHLO
	einhorn.in-berlin.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753510Ab3ALRBS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2013 12:01:18 -0500
In-Reply-To: <20130112162224.10e2aa44@stein>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Jan 12 Stefan Richter wrote:
> At least one thing which is still missing (also
> missing in Stephan's patch from previous week) is the RFC 3146 clause 5
> Configuration ROM entry.

Another thing:  As far as I understand, the current code assumes that
peers will use the same unicast_FIFO for IPv4 unicast as for IPv6
unicast.  This is not necessarily true.  Either firewire-net needs to
maintain two lists of peers (one for IPv4, another for IPv6), or it needs
to maintain two unicast_FIFOs per peer.
-- 
Stefan Richter
-=====-===-= ---= -==--
http://arcgraph.de/sr/
