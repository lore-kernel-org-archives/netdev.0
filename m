From: David Miller <davem@davemloft.net>
Subject: Re: [net 3/3] fcoe: use CHECKSUM_UNNECESSARY instead of
 CHECKSUM_PARTIAL on tx
Date: Mon, 19 Mar 2012 17:38:20 -0400 (EDT)
Message-ID: <20120319.173820.1719327813128013795.davem@davemloft.net>
References: <1331975292-19521-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1331975292-19521-2-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yi.zou@intel.com, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com, JBottomley@parallels.com,
	robert.w.love@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39428 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756151Ab2CSVi1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Mar 2012 17:38:27 -0400
In-Reply-To: <1331975292-19521-2-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Sat, 17 Mar 2012 02:08:12 -0700

> From: Yi Zou <yi.zou@intel.com>
> 
> Fix a bug when using 'ethtool -K ethx tx off' to turn off tx ip checksum,
> FCoE CRC offload should not be impacte. The skb_checksum_help() is needed
> only if it's not FCoE traffic for ip checksum, regardless of ethtool toggling
> the tx ip checksum on or off. Instead of using CHECKSUM_PARTIAL, we will
> use CHECKSUM_UNNECESSARY as a proper indication to avoid sw ip checksum
> on FCoE frames.
> 
> Ref. to original discussion thread:
> http://patchwork.ozlabs.org/patch/146567/
> 
> CC: "James E.J. Bottomley" <JBottomley@parallels.com>
> CC: Robert Love <robert.w.love@intel.com>
> Signed-off-by: Yi Zou <yi.zou@intel.com>
> Tested-by: Ross Brattain <ross.b.brattain@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
