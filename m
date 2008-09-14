From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch v2] net: add Gigabit Ethernet Switch for PCI driver gesp
Date: Sat, 13 Sep 2008 20:28:59 -0400
Message-ID: <48CC5ACB.6030203@pobox.com>
References: <ca0148c30807210325j3cbff1f6i59404171089c82f5@mail.gmail.com> <489A95EA.8000702@pobox.com> <ca0148c30808120512re132edercfebbbd4c97fc2dc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Matti Linnanvuori <mattilinn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:51101 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752527AbYINA3C (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Sep 2008 20:29:02 -0400
In-Reply-To: <ca0148c30808120512re132edercfebbbd4c97fc2dc@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Matti Linnanvuori wrote:
> From: Matti Linnanvuori <matti.linnanvuori@ascom.com>
> 
> Add GESP Gigabit Ethernet Switch for PCI driver.
> 
> Signed-off-by: Matti Linnanvuori <matti.linnanvuori@ascom.com>
> 
> ---
> 
> --- linux-2.6.26/drivers/net/gesp/e1000_82540.c	1970-01-01
> 02:00:00.000000000 +0200
> +++ linux-next/drivers/net/gesp/e1000_82540.c	2008-07-21
> 12:19:29.893549294 +0300
> @@ -0,0 +1,685 @@
> +/*******************************************************************************
> +
> +  Intel PRO/1000 Linux driver
> +  Copyright(c) 1999 - 2008 Intel Corporation.
> +
> +  This program is free software; you can redistribute it and/or modify it
> +  under the terms and conditions of the GNU General Public License,
> +  version 2, as published by the Free Software Foundation.
> +
> +  This program is distributed in the hope it will be useful, but WITHOUT
> +  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
> +  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
> +  more details.
> +
> +  You should have received a copy of the GNU General Public License along with
> +  this program; if not, write to the Free Software Foundation, Inc.,
> +  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
> +
> +  The full GNU General Public License is included in this distribution in
> +  the file called "COPYING".
> +
> +  Contact Information:
> +  Linux NICS <linux.nics@intel.com>
> +  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
> +  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
> +
> +*******************************************************************************/
> +
> +/* e1000_82540
> + * e1000_82545
> + * e1000_82546
> + * e1000_82545_rev_3
> + * e1000_82546_rev_3
> + */
> +
> +#include "e1000_api.h"
> +
> +static s32  e1000_init_phy_params_82540(struct e1000_hw *hw);
> +static s32  e1000_init_nvm_params_82540(struct e1000_hw *hw);
> +static s32  e1000_init_mac_params_82540(struct e1000_hw *hw);
> +static s32  e1000_adjust_serdes_amplitude_82540(struct e1000_hw *hw);
> +static void e1000_clear_hw_cntrs_82540(struct e1000_hw *hw);
> +static s32  e1000_init_hw_82540(struct e1000_hw *hw);
> +static s32  e1000_reset_hw_82540(struct e1000_hw *hw);
> +static s32  e1000_set_phy_mode_82540(struct e1000_hw *hw);
> +static s32  e1000_set_vco_speed_82540(struct e1000_hw *hw);
> +static s32  e1000_setup_copper_link_82540(struct e1000_hw *hw);
> +static s32  e1000_setup_fiber_serdes_link_82540(struct e1000_hw *hw);
> +static void e1000_power_down_phy_copper_82540(struct e1000_hw *hw);

Need a little bit more information here.

How close is this hardware to e1000?

Is this driver really from Intel, as the contact information implies?

Is there documentation on the hardware anywhere?


