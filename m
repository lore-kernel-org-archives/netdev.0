From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 1/3] drivers: of: add phy fixup support in DT
Date: Thu, 25 Apr 2013 03:56:49 -0400 (EDT)
Message-ID: <20130425.035649.1109561373283256109.davem@davemloft.net>
References: <1366654838-26479-1-git-send-email-mugunthanvnm@ti.com>
	<1366654838-26479-2-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	linux-omap@vger.kernel.org
To: mugunthanvnm@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49651 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755342Ab3DYH4v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 03:56:51 -0400
In-Reply-To: <1366654838-26479-2-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mugunthan V N <mugunthanvnm@ti.com>
Date: Mon, 22 Apr 2013 23:50:36 +0530

> In earlier case phy fixup are added in board file as this is no more the case
> so adding support for phy register fixup in Device Tree
> 
> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>

When people put a series of undocumented PHY register writes using
constants, we tell them it's firmware.

If these PHY registers are actually documented in the driver, write a
function in that driver which does the programming sequence, then add
a property that the driver looks for in order to determine whether to
call that sequence or not.

I don't want people putting random PHY raw programming sequences and
other crap like that into the OF device nodes.  It's extremely
inelegant and inviting abuse.
