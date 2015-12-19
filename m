From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: RE: [Intel-wired-lan] [PATCH net-next 2/2] igb: Unpair the queues
 when	changing the number of queues
Date: Sat, 19 Dec 2015 03:25:41 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B81E3136B@ORSMSX101.amr.corp.intel.com>
References: <1449827040-1806-1-git-send-email-suzuki_shota_t3@lab.ntt.co.jp>,<1449827040-1806-2-git-send-email-suzuki_shota_t3@lab.ntt.co.jp>
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
Received: from mga14.intel.com ([192.55.52.115]:27385 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752753AbbLSDZn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2015 22:25:43 -0500
In-Reply-To: <1449827040-1806-2-git-send-email-suzuki_shota_t3@lab.ntt.co.jp>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Intel-wired-lan [intel-wired-lan-bounces@lists.osuosl.org] on behalf of Shota Suzuki 
> [suzuki_shota_t3@lab.ntt.co.jp]
> Sent: Friday, December 11, 2015 1:44 AM
> To: Kirsher, Jeffrey T; Brandeburg, Jesse; Nelson, Shannon; Wyborny, Carolyn; Skidmore, Donald C; 
> Ronciak, John; Williams, Mitch A; intel-wired-lan@lists.osuosl.org; > netdev@vger.kernel.org
> Subject: [Intel-wired-lan] [PATCH net-next 2/2] igb: Unpair the queues when     changing the number of queues
> 
> By the commit 72ddef0506da ("igb: Fix oops caused by missing queue
> pairing"), the IGB_FLAG_QUEUE_PAIRS flag can now be set when changing the
> number of queues by "ethtool -L", but it is never cleared unless the igb
> driver is reloaded.
> This patch clears it if queue pairing becomes unnecessary as a result of
> "ethtool -L".
> 
> Signed-off-by: Shota Suzuki <suzuki_shota_t3@lab.ntt.co.jp>
> ---
>  drivers/net/ethernet/intel/igb/igb_main.c | 2 ++
>  1 file changed, 2 insertions(+)

Tested-by: Aaron Brown <aaron.f.brown@intel.com>