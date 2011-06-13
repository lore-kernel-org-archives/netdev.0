From: Greg Dietsche <gregory.dietsche@cuw.edu>
Subject: Re: [PATCH 1/5] iwlegacy: remove unreachable code
Date: Mon, 13 Jun 2011 09:28:14 -0500
Message-ID: <4DF61E7E.908@cuw.edu>
References: <1307066770-27309-1-git-send-email-Gregory.Dietsche@cuw.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Greg Dietsche <Gregory.Dietsche@cuw.edu>,
	kernel-janitors@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: sgruszka@redhat.com, linville@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1307066770-27309-1-git-send-email-Gregory.Dietsche@cuw.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/02/2011 09:06 PM, Greg Dietsche wrote:
> return; at the end of the function is unecessary.
>
> Signed-off-by: Greg Dietsche<Gregory.Dietsche@cuw.edu>
> ---
>   drivers/net/wireless/iwlegacy/iwl-eeprom.c |    1 -
>   1 files changed, 0 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/net/wireless/iwlegacy/iwl-eeprom.c b/drivers/net/wireless/iwlegacy/iwl-eeprom.c
> index cb346d1..5bf3f49 100644
> --- a/drivers/net/wireless/iwlegacy/iwl-eeprom.c
> +++ b/drivers/net/wireless/iwlegacy/iwl-eeprom.c
> @@ -316,7 +316,6 @@ static void iwl_legacy_init_band_reference(const struct iwl_priv *priv,
>   		break;
>   	default:
>   		BUG();
> -		return;
>   	}
>   }
>
>    

any comments/reviews/acks on this patch series?

thanks,
Greg
