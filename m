From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: RE: [Intel-wired-lan] [PATCH 2/5] e1000e: Fix wrong comment related
 to     link detection
Date: Tue, 19 Sep 2017 00:13:41 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B8C6A191C@ORSMSX101.amr.corp.intel.com>
References: <20170721160937.GA22632@csclub.uwaterloo.ca>
 <20170721183627.13373-1-bpoirier@suse.com>
 <20170721183627.13373-2-bpoirier@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "Lennart Sorensen" <lsorense@csclub.uwaterloo.ca>
To: Benjamin Poirier <bpoirier@suse.com>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170721183627.13373-2-bpoirier@suse.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: Intel-wired-lan [mailto:intel-wired-lan-bounces@osuosl.org] On Behalf
> Of Benjamin Poirier
> Sent: Friday, July 21, 2017 11:36 AM
> To: Kirsher, Jeffrey T <jeffrey.t.kirsher@intel.com>
> Cc: netdev@vger.kernel.org; intel-wired-lan@lists.osuosl.org; linux-
> kernel@vger.kernel.org; Lennart Sorensen <lsorense@csclub.uwaterloo.ca>
> Subject: [Intel-wired-lan] [PATCH 2/5] e1000e: Fix wrong comment related to
> link detection
> 
> Reading e1000e_check_for_copper_link() shows that get_link_status is set to
> false after link has been detected. Therefore, it stays TRUE until then.
> 
> Signed-off-by: Benjamin Poirier <bpoirier@suse.com>
> ---
>  drivers/net/ethernet/intel/e1000e/netdev.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 

Tested-by: Aaron Brown <aaron.f.brown@intel.com>
