From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH v2 1/1] drivers: net: cpsw: discard dual emac
 default vlan configuration
Date: Mon, 26 Jan 2015 16:06:08 -0800 (PST)
Message-ID: <20150126.160608.472412894891698126.davem@davemloft.net>
References: <1421920162-13398-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@vger.kernel.org
To: mugunthanvnm@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46092 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755476AbbA0AGJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 19:06:09 -0500
In-Reply-To: <1421920162-13398-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mugunthan V N <mugunthanvnm@ti.com>
Date: Thu, 22 Jan 2015 15:19:22 +0530

> In Dual EMAC, the default VLANs are used to segregate Rx packets between
> the ports, so adding the same default VLAN to the switch will affect the
> normal packet transfers. So returning error on addition of dual EMAC
> default VLANs.
> 
> Even if EMAC 0 default port VLAN is added to EMAC 1, it will lead to
> break dual EMAC port separations.
> 
> Fixes: d9ba8f9e6298 (driver: net: ethernet: cpsw: dual emac interface implementation)
> Cc: <stable@vger.kernel.org> # v3.9+
> Reported-by: Felipe Balbi <balbi@ti.com>
> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>

Applied, thanks.
