From: Varka Bhadram <varkabhadram@gmail.com>
Subject: Re: [PATCH bluetooth-next] ieee802154: cc2520: Fix space before ,
 coding style issue
Date: Mon, 26 Jan 2015 19:35:38 +0530
Message-ID: <54C649B2.6020902@gmail.com>
References: <1422021327-18815-1-git-send-email-md.jamalmohiuddin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Mohammad Jamal <md.jamalmohiuddin@gmail.com>, alex.aring@gmail.com,
	linux-wpan@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1422021327-18815-1-git-send-email-md.jamalmohiuddin@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jamal,

On Friday 23 January 2015 07:25 PM, Mohammad Jamal wrote:
> This patch removes the warnings (space before , ) shown by
> checkpatch.pl

Thanks for the patch.

Acked-by: Varka Bhadram <varkabhadram@gmail.com>

>
> Signed-off-by: Mohammad Jamal <md.jamalmohiuddin@gmail.com>
> ---
>   drivers/net/ieee802154/cc2520.c |    4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/ieee802154/cc2520.c b/drivers/net/ieee802154/cc2520.c
> index a43c8ac..665a3db 100644
> --- a/drivers/net/ieee802154/cc2520.c
> +++ b/drivers/net/ieee802154/cc2520.c
> @@ -549,14 +549,14 @@ cc2520_ed(struct ieee802154_hw *hw, u8 *level)
>   	u8 rssi;
>   	int ret;
>   
> -	ret = cc2520_read_register(priv , CC2520_RSSISTAT, &status);
> +	ret = cc2520_read_register(priv, CC2520_RSSISTAT, &status);
>   	if (ret)
>   		return ret;
>   
>   	if (status != RSSI_VALID)
>   		return -EINVAL;
>   
> -	ret = cc2520_read_register(priv , CC2520_RSSI, &rssi);
> +	ret = cc2520_read_register(priv, CC2520_RSSI, &rssi);
>   	if (ret)
>   		return ret;
>   

-- 
Thanks and Regards,
Varka Bhadram.
