From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: RE: [Intel-wired-lan] [PATCH net-next v3 1/2] e1000e: factor out
 systim	sanitization
Date: Thu, 4 Aug 2016 19:30:42 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B81F6BB67@ORSMSX101.amr.corp.intel.com>
References: <1469292274-59237-1-git-send-email-jarod@redhat.com>
 <1469557535-63429-1-git-send-email-jarod@redhat.com>
 <1469557535-63429-2-git-send-email-jarod@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
To: Jarod Wilson <jarod@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1469557535-63429-2-git-send-email-jarod@redhat.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: Intel-wired-lan [mailto:intel-wired-lan-bounces@lists.osuosl.org] On
> Behalf Of Jarod Wilson
> Sent: Tuesday, July 26, 2016 11:26 AM
> To: linux-kernel@vger.kernel.org
> Cc: netdev@vger.kernel.org; intel-wired-lan@lists.osuosl.org
> Subject: [Intel-wired-lan] [PATCH net-next v3 1/2] e1000e: factor out systim
> sanitization
> 
> This is prepatory work for an expanding list of adapter families that have
> occasional ~10 hour clock jumps when being used for PTP. Factor out the
> sanitization function and convert to using a feature (bug) flag, per
> suggestion from Jesse Brandeburg.
> 
> Littering functional code with device-specific checks is much messier than
> simply checking a flag, and having device-specific init set flags as needed.
> There are probably a number of other cases in the e1000e code that
> could/should be converted similarly.
> 
> Suggested-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> CC: Jesse Brandeburg <jesse.brandeburg@intel.com>
> CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> CC: intel-wired-lan@lists.osuosl.org
> CC: netdev@vger.kernel.org
> Signed-off-by: Jarod Wilson <jarod@redhat.com>
> ---
>  drivers/net/ethernet/intel/e1000e/82571.c  |  6 ++-
>  drivers/net/ethernet/intel/e1000e/e1000.h  |  1 +
>  drivers/net/ethernet/intel/e1000e/netdev.c | 66 ++++++++++++++++++-------
> -----
>  3 files changed, 44 insertions(+), 29 deletions(-)

Tested-by: Aaron Brown <aaron.f.brown@intel.com>
