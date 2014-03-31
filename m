From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] qlcnic: Fix build failure due to undefined
 reference to `vxlan_get_rx_port'
Date: Mon, 31 Mar 2014 16:29:50 -0400 (EDT)
Message-ID: <20140331.162950.1977000263135313417.davem@davemloft.net>
References: <1396190545-20241-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dept-HSGLinuxNICDev@qlogic.com
To: shahed.shaikh@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42943 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750987AbaCaU35 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2014 16:29:57 -0400
In-Reply-To: <1396190545-20241-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Date: Sun, 30 Mar 2014 10:42:25 -0400

> From: Shahed Shaikh <shahed.shaikh@qlogic.com>
> 
> Commit 2b3d7b758c687("qlcnic: Add VXLAN Rx offload support") uses
> vxlan_get_rx_port() which caused build failure when VXLAN=m.
> 
> This patch fixes the build failure by adding dependency on VXLAN
> in Kconfig of qlcnic module and use vxlan_get_rx_port() accordingly.
> 
> Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
> ---
> Hi David,
> 
> Please apply this patch to net-next.

Do this properly, don't just CPP protect the symbol that fails.

Look at how I40E_VXLAN is used, it protect everything from the
ndo_*() ops to the surrounding support code.
