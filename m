From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH] wlcore: fix spelling mistake in wl1271_warning 'iligal'
 -> 'illegal'
Date: Mon, 03 Apr 2017 02:20:56 -0700
Message-ID: <1491211256.27353.58.camel@perches.com>
References: <20170403091530.18564-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Colin King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
        Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170403091530.18564-1-colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2017-04-03 at 10:15 +0100, Colin King wrote:
> From: Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> 
> trivial fix to spelling mistake in wl1271_warning error message
> 
> Signed-off-by: Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> ---
>  drivers/net/wireless/ti/wlcore/debugfs.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/wireless/ti/wlcore/debugfs.c b/drivers/net/wireless/ti/wlcore/debugfs.c
> index 58e148d7bc7b..416080adc181 100644
> --- a/drivers/net/wireless/ti/wlcore/debugfs.c
> +++ b/drivers/net/wireless/ti/wlcore/debugfs.c
> @@ -1249,7 +1249,7 @@ static ssize_t fw_logger_write(struct file *file,
>  	}
>  
>  	if (wl->conf.fwlog.output == 0) {
> -		wl1271_warning("iligal opperation - fw logger disabled by default, please change mode via wlconf");
> +		wl1271_warning("illegal opperation - fw logger disabled by default, please change mode via wlconf");

Hi Colin.

When you do these would you please fix all the typos on the
same line?  opperation -> operation

Also, generally, invalid is a better word choice than illegal
for these situations.

Thanks and cheers, Joe
