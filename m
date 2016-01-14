From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: RE: [PATCH] igb: add conditions for I210 to generate periodic clock
 output
Date: Thu, 14 Jan 2016 03:22:17 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B81E4F1D6@ORSMSX101.amr.corp.intel.com>
References: <1452497658-20050-1-git-send-email-roland.king.guan.hii@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Hii, Roland King Guan" <roland.king.guan.hii@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452497658-20050-1-git-send-email-roland.king.guan.hii@intel.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: netdev-owner@vger.kernel.org [netdev-owner@vger.kernel.org] on behalf of Roland Hii [roland.king.guan.hii@intel.com]
> Sent: Sunday, January 10, 2016 11:34 PM
> To: Kirsher, Jeffrey T
> Cc: intel-wired-lan@lists.osuosl.org; netdev@vger.kernel.org; linux-kernel@vger.kernel.org
> Subject: [PATCH] igb: add conditions for I210 to generate periodic clock output
> 
> In general case the maximum supported half cycle time of the synchronized
> output clock is 70msec. Slower half cycle time than 70msec can be
> programmed also as long as the output clock is synchronized to whole
> seconds, useful specifically for generating a 1Hz clock.
> 
> Permitted values for the clock half cycle time are: 125,000,000 decimal,
> 250,000,000 decimal and 500,000,000 decimal (equals to 125msec, 250msec
> and 500msec respectively).
> 
> Before this patch, only the half cycle time of less than or equal to 70msec
> uses the I210 clock output function. This patch adds additional conditions
> when half cycle time is equal to 125msec or 250msec or 500msec to use
> clock output function.
> 
> Under other conditions, interrupt driven target time output events method
> is still used to generate the desired clock output.
> 
> Signed-off-by: Roland Hii <roland.king.guan.hii@intel.com>
> ---
>  drivers/net/ethernet/intel/igb/igb_ptp.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)

Tested-by: Aaron Brown <aaron.f.brown@intel.com>
