From: Julian Calaby <julian.calaby@gmail.com>
Subject: Re: [PATCH] brcmfmac: sdio: remove unused variable retry_limit
Date: Mon, 28 Mar 2016 15:16:07 +1100
Message-ID: <CAGRGNgXn8Kjm5Rf3Qr60JdG2x9-=Jqf4WazhPoWTsjUjLKgfOg@mail.gmail.com>
References: <1458495292-17701-1-git-send-email-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Brett Rudley <brudley@broadcom.com>,
	Arend van Spriel <arend@broadcom.com>,
	Franky Lin <frankyl@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	Pieter-Paul Giesberts <pieterpg@broadcom.com>,
	Vineet Gupta <Vineet.Gupta1@synopsys.com>,
	Kosuke Tatsukawa <tatsu@ab.jp.nec.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	brcm80211 development <brcm80211-dev-list@broadcom.com>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Colin King <colin.king@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f43.google.com ([209.85.218.43]:35526 "EHLO
	mail-oi0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751079AbcC1EQ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Mar 2016 00:16:27 -0400
In-Reply-To: <1458495292-17701-1-git-send-email-colin.king@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

On Mon, Mar 21, 2016 at 4:34 AM, Colin King <colin.king@canonical.com> wrote:
> From: Colin Ian King <colin.king@canonical.com>
>
> retry_limit has never been used during the life of this driver, so
> we may as well remove it as it is redundant.
>
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Looks right to me.

Reviewed-by: Julian Calaby <julian.calaby@gmail.com>


> ---
>  drivers/net/wireless/broadcom/brcm80211/brcmfmac/sdio.c | 3 ---
>  1 file changed, 3 deletions(-)
>
> diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/sdio.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/sdio.c
> index 43fd3f4..cd92ba7 100644
> --- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/sdio.c
> +++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/sdio.c
> @@ -535,9 +535,6 @@ static int qcount[NUMPRIO];
>
>  #define RETRYCHAN(chan) ((chan) == SDPCM_EVENT_CHANNEL)
>
> -/* Retry count for register access failures */
> -static const uint retry_limit = 2;
> -
>  /* Limit on rounding up frames */
>  static const uint max_roundup = 512;
>
> --
> 2.7.3
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Julian Calaby

Email: julian.calaby@gmail.com
Profile: http://www.google.com/profiles/julian.calaby/
