From: Grant Grundler <grantgrundler@gmail.com>
Subject: Re: [PATCH] tulip: Poll link status more frequently for Comet chips
Date: Sat, 21 Jun 2014 15:59:30 -0700
Message-ID: <CAP6odjjE3hYXPggagPvF+hYm7nGHQqLqeQ3Ls9jzd=DVBLcJ4w@mail.gmail.com>
References: <1403382541-7129-1-git-send-email-linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Grant Grundler <grundler@parisc-linux.org>,
	"open list:TULIP NETWORK DRI..." <netdev@vger.kernel.org>,
	open list <linux-kernel@vger.kernel.org>
To: Ondrej Zary <linux@rainbow-software.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1403382541-7129-1-git-send-email-linux@rainbow-software.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Ondrej,

On Sat, Jun 21, 2014 at 1:29 PM, Ondrej Zary <linux@rainbow-software.org> wrote:
> Poll link status every 2 seconds instead of 60 for ADMtek Comet chips.

Why use 2 seconds for the polling interval?

I'm sure you have a good reason for this and it should be in the
commit message or as a comment in the code.

I otherwise have no objection to this change.

thanks,
grant

> Tested with AN983B.
>
> Signed-off-by: Ondrej Zary <linux@rainbow-software.org>
> ---
>  drivers/net/ethernet/dec/tulip/timer.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/dec/tulip/timer.c b/drivers/net/ethernet/dec/tulip/timer.c
> index 768379b..523d9dd 100644
> --- a/drivers/net/ethernet/dec/tulip/timer.c
> +++ b/drivers/net/ethernet/dec/tulip/timer.c
> @@ -158,7 +158,7 @@ void comet_timer(unsigned long data)
>  {
>         struct net_device *dev = (struct net_device *)data;
>         struct tulip_private *tp = netdev_priv(dev);
> -       int next_tick = 60*HZ;
> +       int next_tick = 2*HZ;
>
>         if (tulip_debug > 1)
>                 netdev_dbg(dev, "Comet link status %04x partner capability %04x\n",
> --
> Ondrej Zary
