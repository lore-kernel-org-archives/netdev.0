From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: RE: [PATCH] igb: Workaround for igb i210 firmware issue.
Date: Mon, 7 Nov 2016 23:55:35 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B81FC45B5@ORSMSX101.amr.corp.intel.com>
References: <1478096032-22119-1-git-send-email-christopherarges@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Chris J Arges <christopherarges@gmail.com>,
        "jh@henneberg-systemdesign.com" <jh@henneberg-systemdesign.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1478096032-22119-1-git-send-email-christopherarges@gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of Chris J Arges
> Sent: Wednesday, November 2, 2016 7:14 AM
> To: jh@henneberg-systemdesign.com
> Cc: intel-wired-lan@lists.osuosl.org; Chris J Arges
> <christopherarges@gmail.com>; Kirsher, Jeffrey T
> <jeffrey.t.kirsher@intel.com>; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org
> Subject: [PATCH] igb: Workaround for igb i210 firmware issue.
> 
> Sometimes firmware may not properly initialize I347AT4_PAGE_SELECT
> causing
> the probe of an igb i210 NIC to fail. This patch adds an addition zeroing of
> this register during igb_get_phy_id to workaround this issue.
> 
> Thanks for Jochen Henneberg for the idea and original patch.
> 
> Signed-off-by: Chris J Arges <christopherarges@gmail.com>
> ---
>  drivers/net/ethernet/intel/igb/e1000_phy.c | 4 ++++
>  1 file changed, 4 insertions(+)

Tested-by: Aaron Brown <aaron.f.brown@intel.com>
