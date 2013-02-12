From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ixgbe: Only set gso_type to SKB_GSO_TCPV4 as RSC
 does not support IPv6
Date: Tue, 12 Feb 2013 16:07:46 -0500 (EST)
Message-ID: <20130212.160746.324394770336310653.davem@davemloft.net>
References: <20130212193624.17818.13843.stgit@ahduyck-cp1.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com, mst@redhat.com
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56905 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755415Ab3BLVHt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 16:07:49 -0500
In-Reply-To: <20130212193624.17818.13843.stgit@ahduyck-cp1.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Tue, 12 Feb 2013 11:45:44 -0800

> The original fix that was applied for setting gso_type required more change
> than necessary because it was assumed ixgbe does RSC on IPv6 frames and this
> is not correct.  RSC is only supported with IPv4/TCP frames only.  As such we
> can simplify the fix and avoid the unnecessary move of eth_type_trans.
> 
> The previous patch "ixgbe: fix gso type" and this patch reduce the entire fix
> to one line that sets gso_type to TCPV4 if the frame is RSC.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>

Applied.
