From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/6] e1000e: convert register test macros to functions
Date: Tue, 13 Nov 2007 20:54:24 -0800 (PST)
Message-ID: <20071113.205424.71818344.davem@davemloft.net>
References: <20071113231110.13177.27339.stgit@localhost.localdomain>
	<20071113231128.13177.76095.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, jesse.brandeburg@intel.com
To: auke-jan.h.kok@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43557
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758076AbXKNEyY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 23:54:24 -0500
In-Reply-To: <20071113231128.13177.76095.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Auke Kok <auke-jan.h.kok@intel.com>
Date: Tue, 13 Nov 2007 15:11:28 -0800

> From: Joe Perches <joe@perches.com>
> 
> Add functions for reg_pattern_test and reg_set_and check
> Changed macros to use these functions
> 
> Compiled x86, untested
> 
> Size decreased ~2K
> 
> old:
> 
> $ size drivers/net/e1000e/ethtool.o
>    text    data     bss     dec     hex filename
>   14461       0       0   14461    387d drivers/net/e1000e/ethtool.o
> 
> new:
> 
> $ size drivers/net/e1000e/ethtool.o
>    text    data     bss     dec     hex filename
>   12498       0       0   12498    30d2 drivers/net/e1000e/ethtool.o
> 
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>

Applied to netdev-2.6, but I had to fix up the following
whitespace issues by hand:

Adds trailing whitespace.
diff:28:bool reg_pattern_test_array(struct e1000_adapter *adapter, u64 *data, 
Adds trailing whitespace.
diff:33:	static const u32 test[] = 
warning: 2 lines add whitespace errors.

Please correct this before submission in the future.

Thanks!
