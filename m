From: David Miller <davem@davemloft.net>
Subject: Re: [net 2/3] net: do not do gso for CHECKSUM_UNNECESSARY in
 netif_needs_gso
Date: Mon, 19 Mar 2012 17:38:11 -0400 (EDT)
Message-ID: <20120319.173811.1797230836384259872.davem@davemloft.net>
References: <1331975292-19521-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yi.zou@intel.com, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39424 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755973Ab2CSViY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Mar 2012 17:38:24 -0400
In-Reply-To: <1331975292-19521-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Sat, 17 Mar 2012 02:08:11 -0700

> From: Yi Zou <yi.zou@intel.com>
> 
> This is related to fixing the bug of dropping FCoE frames when disabling tx ip
> checksum by 'ethtool -K ethx tx off'. The FCoE protocol stack driver would
> use CHECKSUM_UNNECESSARY on tx path instead of CHECKSUM_PARTIAL (as indicated in
> the 2/2 of this series). To do so, netif_needs_gso() has to be changed here to
> not do gso for both CHECKSUM_PARTIAL and CHECKSUM_UNNECESSARY.
> 
> Ref. to original discussion thread:
> http://patchwork.ozlabs.org/patch/146567/
> 
> Signed-off-by: Yi Zou <yi.zou@intel.com>
> Tested-by: Ross Brattain <ross.b.brattain@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
