From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: RE: [Intel-wired-lan] [PATCH net-next v3 2/2] e1000e: fix PTP on
	e1000_pch_lpt variants
Date: Thu, 4 Aug 2016 19:31:12 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B81F6BB7D@ORSMSX101.amr.corp.intel.com>
References: <1469292274-59237-1-git-send-email-jarod@redhat.com>
 <1469557535-63429-1-git-send-email-jarod@redhat.com>
 <1469557535-63429-3-git-send-email-jarod@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
To: Jarod Wilson <jarod@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1469557535-63429-3-git-send-email-jarod@redhat.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: Intel-wired-lan [mailto:intel-wired-lan-bounces@lists.osuosl.org] On
> Behalf Of Jarod Wilson
> Sent: Tuesday, July 26, 2016 11:26 AM
> To: linux-kernel@vger.kernel.org
> Cc: netdev@vger.kernel.org; intel-wired-lan@lists.osuosl.org
> Subject: [Intel-wired-lan] [PATCH net-next v3 2/2] e1000e: fix PTP on
> e1000_pch_lpt variants
> 
> I've got reports that the Intel I-218V NIC in Intel NUC5i5RYH systems used
> as a PTP slave experiences random ~10 hour clock jumps, which are resolved
> if the same workaround for the 82574 and 82583 is employed, so set the
> appropriate flag2 in e1000_pch_lpt_info too.
> 
> Reported-by: Rupesh Patel <rupatel@redhat.com>
> CC: Jesse Brandeburg <jesse.brandeburg@intel.com>
> CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> CC: intel-wired-lan@lists.osuosl.org
> CC: netdev@vger.kernel.org
> Signed-off-by: Jarod Wilson <jarod@redhat.com>
> ---
>  drivers/net/ethernet/intel/e1000e/ich8lan.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)

Tested-by: Aaron Brown <aaron.f.brown@intel.com>
