From: David Miller <davem@davemloft.net>
Subject: Re: netfilter 00/09: netfilter fixes/trivial patches
Date: Mon, 12 Jan 2009 16:39:11 -0800 (PST)
Message-ID: <20090112.163911.59892780.davem@davemloft.net>
References: <20090112100559.9280.23431.sendpatchset@x2.localnet>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59083
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751366AbZAMAjK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2009 19:39:10 -0500
In-Reply-To: <20090112100559.9280.23431.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 12 Jan 2009 11:05:59 +0100 (MET)

> the following patches contain fixes for a number of netfilter bugs:
> 
> - Herbert's patches to fix VLAN/PPPoE handling in bridge netfilter
> 
> - a fix for an iptables regression in 2.6.28, breaking revision queries
>   for match and target revisions
> 
> - a fix for an ebtables regression in 2.6.28, which inverted the
>   meaning of match result codes
> 
> - a fix for a problem with the ICMP/ICMPv6 conntrack timeout sysctls
>   on big-endian
> 
> Additionally it includes four trivial patches that don't seem worth
> queueing for the next merge window:
> 
> - removal of the "happy cracking" and similar messages
> 
> - simplification of nf_conntrack_alloc() error handling
> 
> - addition of an informational message to the xt_time match
> 
> - reordering of struct xt_match to make it fit into a 128 byte cacheline

All applied, thanks Patrick.

Your GIT tree looked perfectly fine, and the only reason I didn't
pull was that I wanted to practice using bundles with patchwork.

Next time I'll pull direct from your tree :-)
