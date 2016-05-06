From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ipv6: tcp reset, icmp need to consider L3 domain
Date: Fri, 06 May 2016 15:49:21 -0400 (EDT)
Message-ID: <20160506.154921.2216122933773493719.davem@davemloft.net>
References: <1462422368-10822-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48903 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758265AbcEFTtX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2016 15:49:23 -0400
In-Reply-To: <1462422368-10822-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Wed,  4 May 2016 21:26:08 -0700

> Responses for packets to unused ports are getting lost with L3 domains.
> 
> IPv4 has ip_send_unicast_reply for sending TCP responses which accounts
> for L3 domains; update the IPv6 counterpart tcp_v6_send_response.
> For icmp the L3 master check needs to be moved up in icmp6_send
> to properly respond to UDP packets to a port with no listener.
> 
> Fixes: ca254490c8df ("net: Add VRF support to IPv6 stack")
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied and queued up for -stable, thanks.
