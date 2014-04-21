From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] rtlwifi: rtl8188ee: initialize packet_beacon
Date: Mon, 21 Apr 2014 12:15:44 -0500
Message-ID: <53555240.70806@lwfinger.net>
References: <1398098324-5193-1-git-send-email-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:41601 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751318AbaDURPq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2014 13:15:46 -0400
In-Reply-To: <1398098324-5193-1-git-send-email-colin.king@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/21/2014 11:38 AM, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
>
> static code analysis from cppcheck reports:
>
> [drivers/net/wireless/rtlwifi/rtl8188ee/trx.c:322]:
>    (error) Uninitialized variable: packet_beacon
>
> packet_beacon is not initialized and hence packet_beacon
> contains garbage from the stack, so set it to false.
>
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> ---
>   drivers/net/wireless/rtlwifi/rtl8188ee/trx.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)

This change should have a "Cc: Stable <stable@vger.kernel.org> [3.10+] notation.

Other than that, Acked-by: Larry Finger <Larry.Finger@lwfinger.net>

John: Is it possible for you to add stable, or do you want Colin to resubmit.

Larry

>
> diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/trx.c b/drivers/net/wireless/rtlwifi/rtl8188ee/trx.c
> index 06ef47c..5b4c225 100644
> --- a/drivers/net/wireless/rtlwifi/rtl8188ee/trx.c
> +++ b/drivers/net/wireless/rtlwifi/rtl8188ee/trx.c
> @@ -293,7 +293,7 @@ static void _rtl88ee_translate_rx_signal_stuff(struct ieee80211_hw *hw,
>   	u8 *psaddr;
>   	__le16 fc;
>   	u16 type, ufc;
> -	bool match_bssid, packet_toself, packet_beacon, addr;
> +	bool match_bssid, packet_toself, packet_beacon = false, addr;
>
>   	tmp_buf = skb->data + pstatus->rx_drvinfo_size + pstatus->rx_bufshift;
>
>
