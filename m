From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] openvswitch: use flow protocol when recalculating
 ipv6 checksums
Date: Thu, 21 Apr 2016 15:29:40 -0400 (EDT)
Message-ID: <20160421.152940.728927694990381481.davem@davemloft.net>
References: <1461203355-3088-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pshelar@ovn.org, jesse@kernel.org, netdev@vger.kernel.org,
	dev@openvswitch.org, jrajahalme@nicira.com
To: simon.horman@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54791 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752192AbcDUT3l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2016 15:29:41 -0400
In-Reply-To: <1461203355-3088-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <simon.horman@netronome.com>
Date: Thu, 21 Apr 2016 11:49:15 +1000

> When using masked actions the ipv6_proto field of an action
> to set IPv6 fields may be zero rather than the prevailing protocol
> which will result in skipping checksum recalculation.
> 
> This patch resolves the problem by relying on the protocol
> in the flow key rather than that in the set field action.
> 
> Fixes: 83d2b9ba1abc ("net: openvswitch: Support masked set actions.")
> Cc: Jarno Rajahalme <jrajahalme@nicira.com>
> Signed-off-by: Simon Horman <simon.horman@netronome.com>

Looks good to me, applied and queued up for -stable.

Thanks Simon.
