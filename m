From: "David Rivshin (Allworx)" <drivshin.allworx@gmail.com>
Subject: Re: [PATCH net v2 0/3] drivers: net: cpsw: phy-handle fixes
Date: Thu, 21 Apr 2016 00:20:04 -0400
Message-ID: <20160421002004.7a87517e.drivshin.allworx@gmail.com>
References: <1461209082-25609-1-git-send-email-drivshin.allworx@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Grygorii Strashko <grygorii.strashko@ti.com>,
	Andrew Goodbody <andrew.goodbody@cambrionix.com>,
	Heiko Schocher <hs@denx.de>,
	Markus Brunner <systemprogrammierung.brunner@gmail.com>,
	Nicolas Chauvet <kwizart@gmail.com>,
	Pascal Speck <kernel@iktek.de>,
	Daniel Trautmann <dtrautmann@ibhsoftec-sps.de>,
	Tony Lindgren <tony@atomide.com>, devicetree@vger.kernel.org
To: netdev@vger.kernel.org, linux-omap@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f68.google.com ([209.85.192.68]:34029 "EHLO
	mail-qg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750919AbcDUEUI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2016 00:20:08 -0400
In-Reply-To: <1461209082-25609-1-git-send-email-drivshin.allworx@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry all for the noise. Gmail seems to be deciding that this outgoing 
mail is spammy, and starts blocking it part-way through. I've tried 
cutting down the CC list, but still no luck. If anyone knows how to get 
around this (while still having a reasonable patch submission), please 
let me know. 

For tonight, I guess I have no choice but to give up. I'll try again
tomorrow in hopes gmail becomes sane again.


On Wed, 20 Apr 2016 23:24:39 -0400
"David Rivshin (Allworx)" <drivshin.allworx@gmail.com> wrote:

> From: David Rivshin <drivshin@allworx.com>
> 
> The first patch fixes a bug that makes dual_emac mode break if
> either slave uses the phy-handle property in the devicetree.
> 
> The second patch fixes some cosmetic problems with error messages,
> and also makes the binding documentation more explicit.
> 
> The third patch cleans up the fixed-link case to work like
> the now-fixed phy-handle case.
> 
> I have tested on the following hardware configurations:
>  - (EVMSK) dual emac, phy_id property in both slaves
>  - (EVMSK) dual emac, phy-handle property in both slaves
>  - (BeagleBoneBlack) single emac, phy_id property
>  - (custom) single emac, fixed-link subnode
> 
> Nicolas Chauvet reported testing on an HP t410 (dm8148).
> 
> Markus Brunner reported testing v1 on the following [1]:
>  - emac0 with phy_id and emac1 with fixed phy
>  - emac0 with phy-handle and emac1 with fixed phy
>  - emac0 with fixed phy and emac1 with fixed phy
> 
> 
> Changes since v1 [2]:
> - Rebased
> - Added Tested-by from Nicolas Chauvet on all patches
> - Added Acked-by from Rob Herring for the binding change in patch 2 [3]
> 
> [1] http://www.spinics.net/lists/netdev/msg357890.html
> [2] http://www.spinics.net/lists/netdev/msg357772.html
> [3] http://www.spinics.net/lists/netdev/msg358254.html
> 
> David Rivshin (3):
>   drivers: net: cpsw: fix parsing of phy-handle DT property in dual_emac
>     config
>   drivers: net: cpsw: fix error messages when using phy-handle DT
>     property
>   drivers: net: cpsw: use of_phy_connect() in fixed-link case
> 
>  Documentation/devicetree/bindings/net/cpsw.txt |  4 +--
>  drivers/net/ethernet/ti/cpsw.c                 | 41 +++++++++++++-------------
>  drivers/net/ethernet/ti/cpsw.h                 |  1 +
>  3 files changed, 23 insertions(+), 23 deletions(-)
> 
