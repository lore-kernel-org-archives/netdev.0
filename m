From: "Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>
Subject: RE: [PATCH 4/7] iwlwifi: fix a problematic usage of WARN_ON_ONCE()
Date: Wed, 25 Nov 2015 13:47:42 +0000
Message-ID: <0BA3FCBA62E2DC44AF3030971E174FB32E8FC5E8@hasmsx107.ger.corp.intel.com>
References: <86c73f180d3054c1bf17bdac8c89026209167c9b.1448456395.git.geliangtang@163.com>
 <8bb789c0803579a01e1ee977ed67408c422acd79.1448456395.git.geliangtang@163.com>
 <582529c23f77af64373f59fa92e29186df700d79.1448456395.git.geliangtang@163.com>
 <7701ed112cc71a9a17ba5b3022166011a98d0dca.1448456395.git.geliangtang@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Geliang Tang <geliangtang@163.com>,
	"Berg, Johannes" <johannes.berg@intel.com>,
	linuxwifi <linuxwifi@intel.com>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <7701ed112cc71a9a17ba5b3022166011a98d0dca.1448456395.git.geliangtang@163.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> 
> WARN_ON_ONCE() takes a condition rather than a format string. This patch
> converted WARN_ON_ONCE() to WARN_ONCE() instead.
> 
> Signed-off-by: Geliang Tang <geliangtang@163.com>
> ---
>  drivers/net/wireless/intel/iwlwifi/mvm/rs.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

Already fixed. Thanks.

> 
> diff --git a/drivers/net/wireless/intel/iwlwifi/mvm/rs.c
> b/drivers/net/wireless/intel/iwlwifi/mvm/rs.c
> index d1ad103..58d7bee 100644
> --- a/drivers/net/wireless/intel/iwlwifi/mvm/rs.c
> +++ b/drivers/net/wireless/intel/iwlwifi/mvm/rs.c
> @@ -1827,7 +1827,7 @@ static int rs_switch_to_column(struct iwl_mvm
> *mvm,
>  		rate->type = lq_sta->is_vht ? LQ_VHT_MIMO2 :
> LQ_HT_MIMO2;
>  		rate_mask = lq_sta->active_mimo2_rate;
>  	} else {
> -		WARN_ON_ONCE("Bad column mode");
> +		WARN_ONCE(1, "Bad column mode");
>  	}
> 
>  	if (column->mode != RS_LEGACY) {
> --
> 2.5.0
> 
