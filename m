From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vxlan: Fix error that was resulting in VXLAN MTU size
 being 10 bytes too large
Date: Tue, 13 Nov 2012 14:37:19 -0500 (EST)
Message-ID: <20121113.143719.1473223615602040380.davem@davemloft.net>
References: <20121109233354.17208.36271.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48379 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754815Ab2KMThU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2012 14:37:20 -0500
In-Reply-To: <20121109233354.17208.36271.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Fri, 09 Nov 2012 15:35:24 -0800

> This change fixes an issue I found where VXLAN frames were fragmented when
> they were up to the VXLAN MTU size.  I root caused the issue to the fact that
> the headroom was 4 + 20 + 8 + 8.  This math doesn't appear to be correct
> because we are not inserting a VLAN header, but instead a 2nd Ethernet header.
> As such the math for the overhead should be 20 + 8 + 8 + 14 to account for the
> extra headers that are inserted for VXLAN.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>

Applied, thanks for the detailed commit message.
