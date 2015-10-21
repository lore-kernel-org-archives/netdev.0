From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 15/15] net: wireless: ath: Remove unneeded variable ret
 returning 0
Date: Thu, 22 Oct 2015 00:46:47 +0300
Message-ID: <562807C7.2020701@cogentembedded.com>
References: <1445439337-19055-1-git-send-email-punitvara@gmail.com>
 <1445439337-19055-16-git-send-email-punitvara@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: stas.yakovlev@gmail.com, chaoming_li@realsil.com.cn,
	Larry.Finger@lwfinger.net, chunkeey@googlemail.com,
	sgruszka@redhat.com, brudley@broadcom.com, arend@broadcom.com,
	linville@tuxdriver.com, jirislaby@gmail.com, mickflemm@gmail.com,
	mcgrof@do-not-panic.com, k.eugene.e@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	brcm80211-dev-list@broadcom.com, wcn36xx@lists.infradead.org,
	johannes.berg@intel.com, meuleman@broadcom.com
To: Punit Vara <punitvara@gmail.com>, kvalo@qca.qualcomm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445439337-19055-16-git-send-email-punitvara@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/21/2015 05:55 PM, Punit Vara wrote:

> This patch is to the ath5k/eeprom.c that fixes up warning caught by
> coccicheck:
>
> Unneeded variable: "ret". Return "0" on line 980
>
> Remove unneeded variable ret created to return zero.
>
> Signed-off-by: Punit Vara <punitvara@gmail.com>
> ---
>   drivers/net/wireless/ath/wcn36xx/main.c | 3 +--
>   1 file changed, 1 insertion(+), 2 deletions(-)
>
> diff --git a/drivers/net/wireless/ath/wcn36xx/main.c b/drivers/net/wireless/ath/wcn36xx/main.c
> index 7c169ab..82982d5 100644
> --- a/drivers/net/wireless/ath/wcn36xx/main.c
> +++ b/drivers/net/wireless/ath/wcn36xx/main.c
> @@ -935,7 +935,6 @@ static const struct ieee80211_ops wcn36xx_ops = {
>
>   static int wcn36xx_init_ieee80211(struct wcn36xx *wcn)
>   {
> -	int ret = 0;
>

   This empty line should be removed too.

>   	static const u32 cipher_suites[] = {
>   		WLAN_CIPHER_SUITE_WEP40,
[...]

MBR, Sergei
