From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/6] e1000: convert regtest macro's to functions
Date: Tue, 13 Nov 2007 20:52:27 -0800 (PST)
Message-ID: <20071113.205227.185844387.davem@davemloft.net>
References: <20071113231110.13177.27339.stgit@localhost.localdomain>
	<20071113231123.13177.75051.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, jesse.brandeburg@intel.com
To: auke-jan.h.kok@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46461
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757523AbXKNEw2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 23:52:28 -0500
In-Reply-To: <20071113231123.13177.75051.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Auke Kok <auke-jan.h.kok@intel.com>
Date: Tue, 13 Nov 2007 15:11:23 -0800

> Minimal macro to function conversion in e1000_ethtool.c
> 
> Adds functions reg_pattern_test and reg_set_and_check
> Changes REG_PATTERN_TEST and REG_SET_AND_CHECK macros
> to call these functions.
> 
> Saves ~2.5KB
> 
> Compiled x86, untested (no hardware)
> 
> old:
> 
> $ size drivers/net/e1000/e1000_ethtool.o
>    text    data     bss     dec     hex filename
>   16778       0       0   16778    418a drivers/net/e1000/e1000_ethtool.o
> 
> new:
> 
> $ size drivers/net/e1000/e1000_ethtool.o
>    text    data     bss     dec     hex filename
>   14128       0       0   14128    3730 drivers/net/e1000/e1000_ethtool.o
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>

Definitely this looks nicer :-)

Applied to netdev-2.6, thanks!
