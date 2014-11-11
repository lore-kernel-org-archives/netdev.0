From: Johan Hovold <johan@kernel.org>
Subject: Re: [PATCH 00/22] net: phy: refactoring and Micrel features
Date: Tue, 11 Nov 2014 19:00:24 +0100
Message-ID: <20141111180024.GG29789@localhost>
References: <1415727460-20417-1-git-send-email-johan@kernel.org>
 <20141111.124936.272547351489598665.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johan@kernel.org, f.fainelli@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	bth@kamstrup.dk
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141111.124936.272547351489598665.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 11, 2014 at 12:49:36PM -0500, David Miller wrote:
> 22 patches is just too much, sorry.
> 
> Please reduce this down to something closer to ~10 or so patches.
> 
> If necessary you can do two series, submit the first 10 and then
> when that's reviewed and accepted submit the second set.

No problem. The three driver-registration patches are really
self-contained and could be reviewed and applied separately, and then I
split the remaining ones where I add the device-type abstraction, that
is:

Series 1:
  net: phy: add module_phy_driver macro
  net: phy: replace phy_driver_register calls
  net: phy: replace phy_drivers_register calls

Series 2:
  dt/bindings: fix documentation of ethernet-phy compatible property
  net: phy: micrel: fix config_intr error handling
  net: phy: micrel: use BIT macro
  net: phy: micrel: refactor broadcast disable
  net: phy: micrel: disable broadcast for KSZ8081/KSZ8091
  net: phy: micrel: add led-mode sanity check
  net: phy: micrel: refactor led-mode error handling
  net: phy: micrel: clean up led-mode setup
  net: phy: micrel: enable led-mode for KSZ8081/KSZ8091

Series 3 (submitted after review of Series 2):
  net: phy: add static data field to struct phy_driver
  net: phy: micrel: add device-type abstraction
  net: phy: micrel: parse of nodes at probe
  net: phy: micrel: add has-broadcast-disable flag to type data
  net: phy: micrel: add generic rmii-ref-clk-sel support
  net: phy: micrel: add support for rmii_ref_clk_sel to KSZ8081/KSZ8091
  dt/bindings: add micrel,rmii_ref_clk_sel_25_mhz to eth-phy binding
  net: phy: micrel: refactor interrupt config
  net: phy: micrel: add copyright entry
  net: phy: micrel: use generic config_init for KSZ8021/KSZ8031

Thanks,
Johan
