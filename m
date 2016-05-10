From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: RE: [PATCH] igb: adjust ptp timestamps for tx/rx latency
Date: Tue, 10 May 2016 01:31:49 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B81EFAB94@ORSMSX101.amr.corp.intel.com>
References: <1462317056-28805-1-git-send-email-nathan.sullivan@ni.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Nathan Sullivan <nathan.sullivan@ni.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Nelson, Shannon" <shannon.nelson@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462317056-28805-1-git-send-email-nathan.sullivan@ni.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of Nathan Sullivan
> Sent: Tuesday, May 3, 2016 4:11 PM
> To: Kirsher, Jeffrey T <jeffrey.t.kirsher@intel.com>; Brandeburg, Jesse
> <jesse.brandeburg@intel.com>; Nelson, Shannon
> <shannon.nelson@intel.com>; Wyborny, Carolyn
> <carolyn.wyborny@intel.com>; Skidmore, Donald C
> <donald.c.skidmore@intel.com>; Allan, Bruce W <bruce.w.allan@intel.com>;
> Ronciak, John <john.ronciak@intel.com>; Williams, Mitch A
> <mitch.a.williams@intel.com>
> Cc: intel-wired-lan@lists.osuosl.org; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; Nathan Sullivan <nathan.sullivan@ni.com>
> Subject: [PATCH] igb: adjust ptp timestamps for tx/rx latency
> 
> Table 7-62 on page 338 of the i210 datasheet lists TX and RX latencies
> for the various speeds the chip supports.  To give better ptp timestamp
> accuracy, adjust the timestamps by the amounts Intel gives based on
> current link speed.
> 
> Signed-off-by: Nathan Sullivan <nathan.sullivan@ni.com>
> ---
>  drivers/net/ethernet/intel/igb/igb.h     |    8 +++++++
>  drivers/net/ethernet/intel/igb/igb_ptp.c |   36
> ++++++++++++++++++++++++++++++
>  2 files changed, 44 insertions(+)

Tested-by: Aaron Brown <aaron.f.brown@intel.com>
