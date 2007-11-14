From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/6] e1000: Secondary unicast address support
Date: Tue, 13 Nov 2007 20:55:13 -0800 (PST)
Message-ID: <20071113.205513.74596942.davem@davemloft.net>
References: <20071113231110.13177.27339.stgit@localhost.localdomain>
	<20071113231133.13177.84769.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, jesse.brandeburg@intel.com
To: auke-jan.h.kok@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43561
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755855AbXKNEzO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 23:55:14 -0500
In-Reply-To: <20071113231133.13177.84769.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Auke Kok <auke-jan.h.kok@intel.com>
Date: Tue, 13 Nov 2007 15:11:33 -0800

> From: Patrick McHardy <kaber@trash.net>
> 
> Add support for configuring secondary unicast addresses. Unicast
> addresses take precendece over multicast addresses when filling
> the exact address filters to avoid going to promiscous mode.
> When more unicast addresses are present than filter slots,
> unicast filtering is disabled and all slots can be used for
> multicast addresses.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>

Applied to netdev-2.6, thanks!
