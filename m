From: Arend Van Spriel <arend.vanspriel@broadcom.com>
Subject: Re: [PATCH 1/1] brcm80211: simplify assignment
Date: Wed, 18 May 2016 11:02:51 +0200
Message-ID: <573C2FBB.2010809@broadcom.com>
References: <1463533033-13336-1-git-send-email-xypron.glpk@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, brcm80211-dev-list@broadcom.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Heinrich Schuchardt <xypron.glpk@gmx.de>,
	Brett Rudley <brudley@broadcom.com>,
	Arend van Spriel <arend@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463533033-13336-1-git-send-email-xypron.glpk@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 18-5-2016 2:57, Heinrich Schuchardt wrote:
> Simplify assignment in wlc_phy_rxcal_gainctrl_nphy_rev5.

Acked-by: Arend van Spriel <arend.vanspriel@broadcom.com>
> Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>
> ---
>  drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy/phy_n.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy/phy_n.c b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy/phy_n.c
> index 99dac9b..b3aab2f 100644
> --- a/drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy/phy_n.c
> +++ b/drivers/net/wireless/broadcom/brcm80211/brcmsmac/phy/phy_n.c
> @@ -27017,7 +27017,7 @@ wlc_phy_rxcal_gainctrl_nphy_rev5(struct brcms_phy *pi, u8 rx_core,
>  		tx_core = 1 - rx_core;
>  
>  	num_samps = 1024;
> -	desired_log2_pwr = (cal_type == 0) ? 13 : 13;
> +	desired_log2_pwr = 13;
>  
>  	wlc_phy_rx_iq_coeffs_nphy(pi, 0, &save_comp);
>  	zero_comp.a0 = zero_comp.b0 = zero_comp.a1 = zero_comp.b1 = 0x0;
> 
