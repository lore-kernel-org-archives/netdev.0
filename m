From: Jiri Slaby <jirislaby@gmail.com>
Subject: Re: [PATCH 01/15] net: wireless: ath: use | instead of + for summing
 bitmasks
Date: Wed, 21 Oct 2015 16:58:48 +0200
Message-ID: <5627A828.9000009@gmail.com>
References: <1445439337-19055-1-git-send-email-punitvara@gmail.com>
 <1445439337-19055-2-git-send-email-punitvara@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Cc: stas.yakovlev@gmail.com, chaoming_li@realsil.com.cn,
	Larry.Finger@lwfinger.net, chunkeey@googlemail.com,
	sgruszka@redhat.com, brudley@broadcom.com, arend@broadcom.com,
	linville@tuxdriver.com, mickflemm@gmail.com,
	mcgrof@do-not-panic.com, k.eugene.e@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	brcm80211-dev-list@broadcom.com, wcn36xx@lists.infradead.org,
	johannes.berg@intel.com, meuleman@broadcom.com
To: Punit Vara <punitvara@gmail.com>, kvalo@qca.qualcomm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445439337-19055-2-git-send-email-punitvara@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/21/2015, 04:55 PM, Punit Vara wrote:
> This patch is to the ath10k/pci.h file that fixes following warning
>  reported by coccicheck:
> 
> WARNING: sum of probable bitmasks, consider |
> 
> I have replaced + with OR operator | for summing bitmasks
> 
> Signed-off-by: Punit Vara <punitvara@gmail.com>
> ---
>  drivers/net/wireless/ath/ath10k/pci.c | 10 +++++-----
>  1 file changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/net/wireless/ath/ath10k/pci.c b/drivers/net/wireless/ath/ath10k/pci.c
> index 1046ab6..165a318 100644
> --- a/drivers/net/wireless/ath/ath10k/pci.c
> +++ b/drivers/net/wireless/ath/ath10k/pci.c
> @@ -775,7 +775,7 @@ static u32 ath10k_pci_targ_cpu_to_ce_addr(struct ath10k *ar, u32 addr)
>  	switch (ar->hw_rev) {
>  	case ATH10K_HW_QCA988X:
>  	case ATH10K_HW_QCA6174:
> -		val = (ath10k_pci_read32(ar, SOC_CORE_BASE_ADDRESS +
> +		val = (ath10k_pci_read32(ar, SOC_CORE_BASE_ADDRESS |
>  					  CORE_CTRL_ADDRESS) &

Could you explain where exactly are 2 bitmasks here?

thanks,
-- 
js
