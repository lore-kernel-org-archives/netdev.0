From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: RE: [PATCH] e1000e: fix division by zero on jumbo MTUs
Date: Fri, 20 Nov 2015 04:45:57 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B81D3DAAE@ORSMSX101.amr.corp.intel.com>
References: <1444729698-9441-1-git-send-email-leonid@daynix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Nelson, Shannon" <shannon.nelson@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Vick, Matthew" <matthew.vick@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Dmitry Fleytman <dmitry@daynix.com>
To: Leonid Bloch <leonid@daynix.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444729698-9441-1-git-send-email-leonid@daynix.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of Leonid Bloch
> Sent: Tuesday, October 13, 2015 2:48 AM
> To: linux-kernel@vger.kernel.org
> Cc: Kirsher, Jeffrey T <jeffrey.t.kirsher@intel.com>; Brandeburg, Jesse
> <jesse.brandeburg@intel.com>; Nelson, Shannon
> <shannon.nelson@intel.com>; Wyborny, Carolyn
> <carolyn.wyborny@intel.com>; Skidmore, Donald C
> <donald.c.skidmore@intel.com>; Vick, Matthew <matthew.vick@intel.com>;
> Ronciak, John <john.ronciak@intel.com>; Williams, Mitch A
> <mitch.a.williams@intel.com>; intel-wired-lan@lists.osuosl.org;
> netdev@vger.kernel.org; Dmitry Fleytman <dmitry@daynix.com>
> Subject: [PATCH] e1000e: fix division by zero on jumbo MTUs
> 
> From: Dmitry Fleytman <dmitry@daynix.com>
> 
> This patch fixes possible division by zero in receive
> interrupt handler when working without adaptive interrupt
> moderation.
> 
> The adaptive interrupt moderation mechanism is typically
> disabled on jumbo MTUs.
> 
> Signed-off-by: Dmitry Fleytman <dmitry@daynix.com>
> Signed-off-by: Leonid Bloch <leonid@daynix.com>
> ---
>  drivers/net/ethernet/intel/e1000e/netdev.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)

Tested-by: Aaron Brown <aaron.f.brown@intel.com>
