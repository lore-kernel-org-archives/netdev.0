From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] xen-netback: make sure skb linear area covers
 checksum field
Date: Wed, 11 Dec 2013 16:47:16 -0500 (EST)
Message-ID: <20131211.164716.1397098528848980750.davem@davemloft.net>
References: <1386779860-19338-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xen.org, netdev@vger.kernel.org,
	wei.liu2@citrix.com, ian.campbell@citrix.com,
	david.vrabel@citrix.com
To: paul.durrant@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59899 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750992Ab3LKVrT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 16:47:19 -0500
In-Reply-To: <1386779860-19338-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Durrant <paul.durrant@citrix.com>
Date: Wed, 11 Dec 2013 16:37:40 +0000

> skb_partial_csum_set requires that the linear area of the skb covers the
> checksum field. The checksum setup code in netback was only doing that
> pullup in the case when the pseudo header checksum was being recalculated
> though. This patch makes that pullup unconditional. (I pullup the whole
> transport header just for simplicity; the requirement is only for the check
> field but in the case of UDP this is the last field in the header and in the
> case of TCP it's the last but one).
> 
> The lack of pullup manifested as failures running Microsoft HCK network
> tests on a pair of Windows 8 VMs and it has been verified that this patch
> fixes the problem.
> 
> Signed-off-by: Paul Durrant <paul.durrant@citrix.com>

Applied, thank you.
