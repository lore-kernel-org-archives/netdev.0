From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] arp: allow arp processing to honor per interface
 arp_accept sysctl
Date: Fri, 16 Mar 2012 23:00:40 -0700 (PDT)
Message-ID: <20120316.230040.750082168470218493.davem@davemloft.net>
References: <1331825158-17584-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39826 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752826Ab2CQGBr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Mar 2012 02:01:47 -0400
In-Reply-To: <1331825158-17584-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Thu, 15 Mar 2012 11:25:58 -0400

> I found recently that the arp_process function which handles all of our received
> arp frames, is using IPV4_DEVCONF_ALL macro to check the state of the arp_process
> flag.  This seems wrong, as it implies that either none or all of the network
> interfaces accept gratuitous arps.  This patch corrects that, allowing
> per-interface arp_accept configuration to deviate from the all setting.  Note
> this also brings us into line with the way the arp_filter setting is handled
> during arp_process execution.
> 
> Tested this myself on my home network, and confirmed it works as expected.
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

Applied to net-next, thanks Neil.
