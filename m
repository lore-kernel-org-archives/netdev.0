From: Stefan Wahren <stefan.wahren-eS4NqCHxEME@public.gmane.org>
Subject: Re: [PATCH v5 16/17] tty: serdev-ttyport: return actual baudrate from
 ttyport_set_baudrate
Date: Wed, 17 May 2017 13:58:05 +0200
Message-ID: <d5533816-5d87-3772-19c0-5e57e519a3f1@i2se.com>
References: <1494406408-31760-1-git-send-email-stefan.wahren@i2se.com>
 <1494406408-31760-17-git-send-email-stefan.wahren@i2se.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>, Jiri Slaby <jslaby-IBi9RG/b67k@public.gmane.org>,
        linux-serial-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Lino Sanfilippo <LinoSanfilippo-Mmb7MZpHnFY@public.gmane.org>,
        Jakub Kicinski <kubakici-5tc4TXWwyLM@public.gmane.org>
To: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1494406408-31760-17-git-send-email-stefan.wahren-eS4NqCHxEME@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Greg,

Am 10.05.2017 um 10:53 schrieb Stefan Wahren:
> Instead of returning the requested baudrate, we better return the
> actual one because it isn't always the same.
>
> Signed-off-by: Stefan Wahren <stefan.wahren-eS4NqCHxEME@public.gmane.org>
> Acked-by: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> ---
>  drivers/tty/serdev/serdev-ttyport.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/tty/serdev/serdev-ttyport.c b/drivers/tty/serdev/serdev-ttyport.c
> index 487c88f..2cfdf34 100644
> --- a/drivers/tty/serdev/serdev-ttyport.c
> +++ b/drivers/tty/serdev/serdev-ttyport.c
> @@ -151,7 +151,7 @@ static unsigned int ttyport_set_baudrate(struct serdev_controller *ctrl, unsigne
>  
>  	/* tty_set_termios() return not checked as it is always 0 */
>  	tty_set_termios(tty, &ktermios);
> -	return speed;
> +	return ktermios.c_ospeed;
>  }
>  
>  static void ttyport_set_flow_control(struct serdev_controller *ctrl, bool enable)

there is no dependency to this series. I would be happy if this could be
applied, so i don't have to carry it for the next version.

Thanks
Stefan
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
