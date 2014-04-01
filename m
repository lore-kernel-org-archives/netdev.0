From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] qlcnic: Fix build failure due to undefined
 reference to `vxlan_get_rx_port'
Date: Tue, 01 Apr 2014 17:38:21 -0400 (EDT)
Message-ID: <20140401.173821.615428156465652582.davem@davemloft.net>
References: <1396384172-28007-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dept-HSGLinuxNICDev@qlogic.com
To: shahed.shaikh@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55976 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751792AbaDAViX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2014 17:38:23 -0400
In-Reply-To: <1396384172-28007-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Date: Tue, 1 Apr 2014 16:29:32 -0400

> From: Shahed Shaikh <shahed.shaikh@qlogic.com>
> 
> Commit 2b3d7b758c687("qlcnic: Add VXLAN Rx offload support") uses
> vxlan_get_rx_port() which caused build failure when VXLAN=m.
> 
> This patch fixes the build failure by adding dependency on VXLAN
> in Kconfig of qlcnic module and use vxlan_get_rx_port() and support
> code accordingly.
> 
> Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>

Applied, thanks.
