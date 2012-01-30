From: Jiri Slaby <jirislaby@gmail.com>
Subject: Re: [PATCH 11/16] ath5k: make ath5k_modparam_no_hw_rfkill_switch
 real
Date: Mon, 30 Jan 2012 23:11:51 +0100
Message-ID: <4F2715A7.9030101@gmail.com>
References: <1327960820-11867-1-git-send-email-danny.kukawka@bisect.de> <1327960820-11867-12-git-send-email-danny.kukawka@bisect.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
Cc: ath5k-devel@lists.ath5k.org, Nick Kossifidis <mickflemm@gmail.com>,
	"Luis R. Rodriguez" <mcgrof@qca.qualcomm.com>,
	Bob Copeland <me@bobcopeland.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Danny Kukawka <danny.kukawka@bisect.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1327960820-11867-12-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/30/2012 11:00 PM, Danny Kukawka wrote:
> Make ath5k_modparam_no_hw_rfkill_switch real bool to fix:
> 'warning: return from incompatible pointer type' compiler warning.

Hi, I'm afraid you are too late:
http://git.kernel.org/?p=linux/kernel/git/next/linux-next.git;a=commitdiff;h=11deb53328a06ad4edbf774f5c3b61c6dbb9104c

> Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
> ---
>  drivers/net/wireless/ath/ath5k/base.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/wireless/ath/ath5k/base.c b/drivers/net/wireless/ath/ath5k/base.c
> index d366dad..ad2f115 100644
> --- a/drivers/net/wireless/ath/ath5k/base.c
> +++ b/drivers/net/wireless/ath/ath5k/base.c
> @@ -80,7 +80,7 @@ static bool modparam_fastchanswitch;
>  module_param_named(fastchanswitch, modparam_fastchanswitch, bool, S_IRUGO);
>  MODULE_PARM_DESC(fastchanswitch, "Enable fast channel switching for AR2413/AR5413 radios.");
>  
> -static int ath5k_modparam_no_hw_rfkill_switch;
> +static bool ath5k_modparam_no_hw_rfkill_switch;
>  module_param_named(no_hw_rfkill_switch, ath5k_modparam_no_hw_rfkill_switch,
>  								bool, S_IRUGO);
>  MODULE_PARM_DESC(no_hw_rfkill_switch, "Ignore the GPIO RFKill switch state");

thanks,
-- 
js
