From: Grant Grundler <grantgrundler@gmail.com>
Subject: Re: [PATCH] net: tulip: remove deprecated IRQF_DISABLED
Date: Wed, 11 Sep 2013 23:05:56 -0700
Message-ID: <CAP6odjg63+g1gLMS9F+O1fQXwFZud10L11P5irJWdQsuDuNXaA@mail.gmail.com>
References: <1378959624-4123-1-git-send-email-michael.opdenacker@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Grant Grundler <grundler@parisc-linux.org>,
	"open list:TULIP NETWORK DRI..." <netdev@vger.kernel.org>,
	open list <linux-kernel@vger.kernel.org>
To: Michael Opdenacker <michael.opdenacker@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1378959624-4123-1-git-send-email-michael.opdenacker@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 11, 2013 at 9:20 PM, Michael Opdenacker
<michael.opdenacker@free-electrons.com> wrote:
> This patch proposes to remove the IRQF_DISABLED flag from
> drivers/net/ethernet/dec/tulip/de4x5.c
>
> It's a NOOP since 2.6.35 and it will be removed one day.

yup - that was easy to confirm.

> Signed-off-by: Michael Opdenacker <michael.opdenacker@free-electrons.com>

Acked-by: Grant Grundler <grundler@parisc-linux.org>

thanks,
grant

> ---
>  drivers/net/ethernet/dec/tulip/de4x5.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/dec/tulip/de4x5.c b/drivers/net/ethernet/dec/tulip/de4x5.c
> index 2db6c57..263b92c 100644
> --- a/drivers/net/ethernet/dec/tulip/de4x5.c
> +++ b/drivers/net/ethernet/dec/tulip/de4x5.c
> @@ -1321,7 +1321,7 @@ de4x5_open(struct net_device *dev)
>      if (request_irq(dev->irq, de4x5_interrupt, IRQF_SHARED,
>                                                      lp->adapter_name, dev)) {
>         printk("de4x5_open(): Requested IRQ%d is busy - attemping FAST/SHARE...", dev->irq);
> -       if (request_irq(dev->irq, de4x5_interrupt, IRQF_DISABLED | IRQF_SHARED,
> +       if (request_irq(dev->irq, de4x5_interrupt, IRQF_SHARED,
>                                                      lp->adapter_name, dev)) {
>             printk("\n              Cannot get IRQ- reconfigure your hardware.\n");
>             disable_ast(dev);
> --
> 1.8.1.2
>
