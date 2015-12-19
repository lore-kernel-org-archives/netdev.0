From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: RE: [PATCH net-next 1/2] igb: Remove unnecessary flag setting in
 igb_set_flag_queue_pairs()
Date: Sat, 19 Dec 2015 03:24:15 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B81E3134E@ORSMSX101.amr.corp.intel.com>
References: <1449827040-1806-1-git-send-email-suzuki_shota_t3@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Shota Suzuki <suzuki_shota_t3@lab.ntt.co.jp>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Nelson, Shannon" <shannon.nelson@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"matthew.vick@intel.com" <matthew.vick@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:65514 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752753AbbLSDYR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2015 22:24:17 -0500
In-Reply-To: <1449827040-1806-1-git-send-email-suzuki_shota_t3@lab.ntt.co.jp>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: netdev-owner@vger.kernel.org [netdev-owner@vger.kernel.org] on behalf of Shota Suzuki 
> [suzuki_shota_t3@lab.ntt.co.jp]
> Sent: Friday, December 11, 2015 1:43 AM
> To: Kirsher, Jeffrey T; Brandeburg, Jesse; Nelson, Shannon; Wyborny, Carolyn; Skidmore, Donald C; 
> Ronciak, John; Williams, Mitch A; intel-wired-lan@lists.osuosl.org; netdev@vger.kernel.org
> Cc: suzuki_shota_t3@lab.ntt.co.jp
> Subject: [PATCH net-next 1/2] igb: Remove unnecessary flag setting in igb_set_flag_queue_pairs()
> 
> If VFs are enabled (max_vfs >= 1), both max_rss_queues and
> adapter->rss_queues are set to 2 in the case of e1000_82576.
> In this case, IGB_FLAG_QUEUE_PAIRS is always set in the default block as a
> result of fall-through, thus setting it in the e1000_82576 block is not
> necessary.

> Signed-off-by: Shota Suzuki <suzuki_shota_t3@lab.ntt.co.jp>
> ---
>  drivers/net/ethernet/intel/igb/igb_main.c | 8 --------
>  1 file changed, 8 deletions(-)

Tested-by: Aaron Brown <aaron.f.brown@intel.com>