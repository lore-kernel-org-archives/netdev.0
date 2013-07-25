From: Darren Hart <dvhart@linux.intel.com>
Subject: Re: [PATCH V3 net-next 0/2] pch_gbe: Add MinnowBoard support
Date: Thu, 25 Jul 2013 07:04:36 -0700
Message-ID: <1374761076.9799.2.camel@dvhart-mobl1.amr.corp.intel.com>
References: <cover.1374728627.git.dvhart@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Peter Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	Joe Perches <joe@perches.com>
To: Linux Net Dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:63621 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755438Ab3GYOFE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Jul 2013 10:05:04 -0400
In-Reply-To: <cover.1374728627.git.dvhart@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Shevchenko caught a couple minor errors in V3. I've incorporated
his feedback and sent V4. Please disregard V3.

Thanks,

Darren Hart

On Wed, 2013-07-24 at 22:10 -0700, Darren Hart wrote:
> Add support for the MinnowBoard in the pch_gbe driver. This was
> originally sent to LKML as part of the MinnowBoard support series. That
> is now partially merged and this version of the patch has been isolated
> from those changes and is now completely self-contained.
> 
> Thanks to everyone on Cc for their time in reviewing, the patch series
> is better for it.
> 
> V2:
>   Whitespace cleanup
>   Remove trailing period in messages
>   Comment formatting (added a colon)
>   Use devm_gpio_request_one
>   Fix missing adapter->pdata NULL check in PHY
>   Use netdev style comment blocks
>   Use kernel_ulong_t for driver_data cast
>   Use unsigned for gpio and unsigned long for flags
> V3:
>   Restore /** comment start for file consistency per Joe Perches
>     following his checkpatch.pl patch
>   Make pch_gbe_phy_tx_clk_delay() static per David Miller
> 
> I have included patch 1/2 as it was also marked with "Changes Requested"
> in patchwork. Hopefully resending is the preferred method.
> 
> The following changes since commit 18afa4b028b46f8b45ca64f94aefe717c297b07d:
> 
>   net: Make devnet_rename_seq static (2013-07-24 17:57:26 -0700)
> 
> are available in the git repository at:
> 
>   git://git.infradead.org/users/dvhart/linux-2.6.git minnow/net-next
>   ssh://git.infradead.org/srv/git/users/dvhart/linux-2.6.git minnow/net-next
> 
> and browsable here:
> 
>   http://git.infradead.org/users/dvhart/linux-2.6.git/shortlog/refs/heads/minnow/net-next
> 
> Darren Hart (2):
>   pch_gbe: Use PCH_GBE_PHY_REGS_LEN instead of 32
>   pch_gbe: Add MinnowBoard support
> 
>  drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h    | 15 ++++
>  .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   | 52 +++++++++++-
>  .../net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.c    | 98 ++++++++++++++++++++++
>  .../net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.h    |  1 +
>  4 files changed, 165 insertions(+), 1 deletion(-)
> 

-- 
Darren Hart
Intel Open Source Technology Center
Yocto Project - Linux Kernel
