From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Don't proxy arp respond if iif == rt->dst.dev if
 private VLAN is disabled
Date: Fri, 10 Feb 2012 15:13:54 -0500 (EST)
Message-ID: <20120210.151354.1291294048972149354.davem@davemloft.net>
References: <1328882831-15300-1-git-send-email-tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hawk@comx.dk
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41512 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755209Ab2BJUPF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2012 15:15:05 -0500
In-Reply-To: <1328882831-15300-1-git-send-email-tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Fri, 10 Feb 2012 15:07:11 +0100

> Commit 653241 (net: RFC3069, private VLAN proxy arp support) changed
> the behavior of arp proxy to send arp replies back out on the interface
> the request came in even if the private VLAN feature is disabled.
> 
> Previously we checked rt->dst.dev != skb->dev for in scenarios, when
> proxy arp is enabled on for the netdevice and also when individual proxy
> neighbour entries have been added.
> 
> This patch adds the check back for the pneigh_lookup() scenario.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied, thanks Thomas.
