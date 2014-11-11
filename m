From: David Miller <davem@davemloft.net>
Subject: Re: [net] ixgbe: phy: fix uninitialized status in
 ixgbe_setup_phy_link_tnx
Date: Tue, 11 Nov 2014 16:32:40 -0500 (EST)
Message-ID: <20141111.163240.790809900354066845.davem@davemloft.net>
References: <1415730125-13732-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, netdev@vger.kernel.org, nhorman@redhat.com,
	sassmann@redhat.com, jogreene@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33881 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751412AbaKKVcn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 16:32:43 -0500
In-Reply-To: <1415730125-13732-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 11 Nov 2014 10:22:05 -0800

> From: Daniel Borkmann <dborkman@redhat.com>
> 
> Status variable is never initialized, can carry an arbitrary value
> on the stack and thus may let the function fail.
> 
> Fixes: e90dd2645664 ("ixgbe: Make return values more direct")
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Acked-by: Emil Tantilov <emil.s.tantilov@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, thanks Jeff.
