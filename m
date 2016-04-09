From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: RE: [PATCH -v2] drivers: net: ethernet: intel: e1000e: fix ethtool
 autoneg off for non-copper
Date: Sat, 9 Apr 2016 01:03:50 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B81EE7AE3@ORSMSX101.amr.corp.intel.com>
References: <1459881004-13992-1-git-send-email-danielwa@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Steve Shih <sshih@cisco.com>,
	"xe-kernel@external.cisco.com" <xe-kernel@external.cisco.com>,
	Daniel Walker <dwalker@fifo99.com>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Daniel Walker <danielwa@cisco.com>,
	"Ruinskiy, Dima" <dima.ruinskiy@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Nelson, Shannon" <shannon.nelson@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1459881004-13992-1-git-send-email-danielwa@cisco.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of Daniel Walker
> Sent: Tuesday, April 5, 2016 11:30 AM
> To: Ruinskiy, Dima <dima.ruinskiy@intel.com>; Kirsher, Jeffrey T
> <jeffrey.t.kirsher@intel.com>; Brandeburg, Jesse
> <jesse.brandeburg@intel.com>; Nelson, Shannon
> <shannon.nelson@intel.com>; Wyborny, Carolyn
> <carolyn.wyborny@intel.com>; Skidmore, Donald C
> <donald.c.skidmore@intel.com>; Allan, Bruce W <bruce.w.allan@intel.com>;
> Ronciak, John <john.ronciak@intel.com>; Williams, Mitch A
> <mitch.a.williams@intel.com>
> Cc: Steve Shih <sshih@cisco.com>; xe-kernel@external.cisco.com; Daniel
> Walker <dwalker@fifo99.com>; intel-wired-lan@lists.osuosl.org;
> netdev@vger.kernel.org; linux-kernel@vger.kernel.org
> Subject: [PATCH -v2] drivers: net: ethernet: intel: e1000e: fix ethtool autoneg
> off for non-copper
> 
> From: Steve Shih <sshih@cisco.com>
> 
> This patch fixes the issues for disabling auto-negotiation and forcing
> speed and duplex settings for the non-copper media.
> 
> For non-copper media, e1000_get_settings should return
> ETH_TP_MDI_INVALID for
> eth_tp_mdix_ctrl instead of ETH_TP_MDI_AUTO so subsequent
> e1000_set_settings
> call would not fail with -EOPNOTSUPP.
> 
> e1000_set_spd_dplx should not automatically turn autoneg back on for
> forced
> 1000 Mbps full duplex settings for non-copper media.
> 
> Cc: xe-kernel@external.cisco.com
> Cc: Daniel Walker <dwalker@fifo99.com>
> Signed-off-by: Steve Shih <sshih@cisco.com>
> ---
>  drivers/net/ethernet/intel/e1000e/ethtool.c | 11 +++++++++--
>  1 file changed, 9 insertions(+), 2 deletions(-)

Tested-by: Aaron Brown <aaron.f.brown@intel.com>
