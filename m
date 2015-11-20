From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: RE: [Intel-wired-lan] [PATCH v2] igb: improve handling of
 disconnected	adapters
Date: Fri, 20 Nov 2015 04:40:24 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B81D3DA92@ORSMSX101.amr.corp.intel.com>
References: <1444716624.2870.14.camel@intel.com>
 <1445269924-26739-1-git-send-email-jarod@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
To: Jarod Wilson <jarod@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445269924-26739-1-git-send-email-jarod@redhat.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: Intel-wired-lan [mailto:intel-wired-lan-bounces@lists.osuosl.org] On
> Behalf Of Jarod Wilson
> Sent: Monday, October 19, 2015 8:52 AM
> To: linux-kernel@vger.kernel.org
> Cc: netdev@vger.kernel.org; Jarod Wilson <jarod@redhat.com>; intel-wired-
> lan@lists.osuosl.org
> Subject: [Intel-wired-lan] [PATCH v2] igb: improve handling of disconnected
> adapters
> 
> Clean up array_rd32 so that it uses igb_rd32 the same as rd32, per the
> suggestion of Alexander Duyck, and use io_addr in more places, so that
> we don't have the need to call E1000_REMOVED (which simply looks for a
> null hw_addr) nearly as much.
> 
> CC: Mark Rustad <mark.d.rustad@intel.com>
> CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> CC: Alexander Duyck <alexander.duyck@gmail.com>
> CC: intel-wired-lan@lists.osuosl.org
> CC: netdev@vger.kernel.org
> Acked-by: Alexander Duyck <aduyck@mirantis.com>
> Signed-off-by: Jarod Wilson <jarod@redhat.com>
> ---
> Note: this patch is rebased on Jeff's next-queue/dev-queue branch, which
> already had an earlier revision of this applied, so I've essentially
> reverted a2675ab and applied the revised version of this, squashed them
> together, and here is the end result, which matches the version Alex acked.
> 
>  drivers/net/ethernet/intel/igb/e1000_regs.h |  3 +--
>  drivers/net/ethernet/intel/igb/igb_main.c   | 15 ++-------------
>  2 files changed, 3 insertions(+), 15 deletions(-)
> 

Tested-by: Aaron Brown <aaron.f.brown@intel.com>
