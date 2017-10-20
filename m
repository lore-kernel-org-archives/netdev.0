From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: RE: [Intel-wired-lan] [next-queue PATCH v9 6/6] igb: Add support
 for    CBS offload
Date: Fri, 20 Oct 2017 01:47:02 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B8C6C507C@ORSMSX101.amr.corp.intel.com>
References: <20171017010128.22141-1-vinicius.gomes@intel.com>
 <20171017010128.22141-7-vinicius.gomes@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "rodney.cummings@ni.com" <rodney.cummings@ni.com>,
        "Guedes, Andre" <andre.guedes@intel.com>,
        "jiri@resnulli.us" <jiri@resnulli.us>,
        "Briano, Ivan" <ivan.briano@intel.com>,
        "richardcochran@gmail.com" <richardcochran@gmail.com>,
        "henrik@austad.us" <henrik@austad.us>,
        "jhs@mojatatu.com" <jhs@mojatatu.com>,
        "levipearson@gmail.com" <levipearson@gmail.com>,
        "Ong, Boon Leong" <boon.leong.ong@intel.com>,
        "xiyou.wangcong@gmail.com" <xiyou.wangcong@gmail.com>,
        "Sanchez-Palencia, Jesus" <jesus.sanchez-palencia@intel.com>
To: "Gomes, Vinicius" <vinicius.gomes@intel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:28843 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751620AbdJTBrE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 19 Oct 2017 21:47:04 -0400
In-Reply-To: <20171017010128.22141-7-vinicius.gomes@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Intel-wired-lan [mailto:intel-wired-lan-bounces@osuosl.org] On Behalf
> Of Vinicius Costa Gomes
> Sent: Monday, October 16, 2017 6:01 PM
> To: netdev@vger.kernel.org; intel-wired-lan@lists.osuosl.org
> Cc: rodney.cummings@ni.com; Guedes, Andre <andre.guedes@intel.com>;
> jiri@resnulli.us; Briano, Ivan <ivan.briano@intel.com>;
> richardcochran@gmail.com; henrik@austad.us; jhs@mojatatu.com;
> levipearson@gmail.com; Ong, Boon Leong <boon.leong.ong@intel.com>;
> xiyou.wangcong@gmail.com; Sanchez-Palencia, Jesus <jesus.sanchez-
> palencia@intel.com>
> Subject: [Intel-wired-lan] [next-queue PATCH v9 6/6] igb: Add support for
> CBS offload
> 
> From: Andre Guedes <andre.guedes@intel.com>
> 
> This patch adds support for Credit-Based Shaper (CBS) qdisc offload
> from Traffic Control system. This support enable us to leverage the
> Forwarding and Queuing for Time-Sensitive Streams (FQTSS) features
> from Intel i210 Ethernet Controller. FQTSS is the former 802.1Qav
> standard which was merged into 802.1Q in 2014. It enables traffic
> prioritization and bandwidth reservation via the Credit-Based Shaper
> which is implemented in hardware by i210 controller.
> 
> The patch introduces the igb_setup_tc() function which implements the
> support for CBS qdisc hardware offload in the IGB driver. CBS offload
> is the only traffic control offload supported by the driver at the
> moment.
> 
> FQTSS transmission mode from i210 controller is automatically enabled
> by the IGB driver when the CBS is enabled for the first hardware
> queue. Likewise, FQTSS mode is automatically disabled when CBS is
> disabled for the last hardware queue. Changing FQTSS mode requires NIC
> reset.
> 
> FQTSS feature is supported by i210 controller only.
> 
> Signed-off-by: Andre Guedes <andre.guedes@intel.com>
> ---
>  drivers/net/ethernet/intel/igb/e1000_defines.h |  23 ++
>  drivers/net/ethernet/intel/igb/e1000_regs.h    |   8 +
>  drivers/net/ethernet/intel/igb/igb.h           |   6 +
>  drivers/net/ethernet/intel/igb/igb_main.c      | 347
> +++++++++++++++++++++++++
>  4 files changed, 384 insertions(+)

>From a regression standpoint:
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
