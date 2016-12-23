From: Arend Van Spriel <arend.vanspriel@broadcom.com>
Subject: Re: [PATCH] brcmfmac: fix spelling mistakes on "Ivalid"
Date: Fri, 23 Dec 2016 20:38:51 +0100
Message-ID: <291781bb-801c-0b73-0b60-8081f42c52b4@broadcom.com>
References: <20161223004322.7300-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>,
        Franky Lin <franky.lin@broadcom.com>,
        Hante Meuleman <hante.meuleman@broadcom.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        Pieter-Paul Giesberts <pieter-paul.giesberts@broadcom.com>,
        =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <rafal@milecki.pl>,
        linux-wireless@vger.kernel.org,
        brcm80211-dev-list.pdl@broadcom.com, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161223004322.7300-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 23-12-2016 1:43, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
> 
> Trivial fixes to spelling mistake "Ivalid" to "Invalid" in
> brcmf_err error messages.

Acked-by: Arend van Spriel <arend.vanspriel@broadcom.com>
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> ---
>  drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c
> index 7ffc4ab..15eaf72 100644
> --- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c
> +++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c
> @@ -3971,7 +3971,7 @@ brcmf_configure_wpaie(struct brcmf_if *ifp,
>  			pval |= AES_ENABLED;
>  			break;
>  		default:
> -			brcmf_err("Ivalid unicast security info\n");
> +			brcmf_err("Invalid unicast security info\n");
>  		}
>  		offset++;
>  	}
> @@ -4015,7 +4015,7 @@ brcmf_configure_wpaie(struct brcmf_if *ifp,
>  			wpa_auth |= WPA2_AUTH_1X_SHA256;
>  			break;
>  		default:
> -			brcmf_err("Ivalid key mgmt info\n");
> +			brcmf_err("Invalid key mgmt info\n");
>  		}
>  		offset++;
>  	}
> 
