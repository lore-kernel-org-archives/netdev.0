From: Jon Mason <jon.mason@exar.com>
Subject: Re: [PATCH] vxge: show startup message with KERN_INFO
Date: Tue, 6 Jul 2010 11:08:25 -0500
Message-ID: <20100706160824.GA31635@exar.com>
References: <20100706130203.GA31471@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.exar.com ([204.154.183.83]:25138 "EHLO smtp1.exar.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752838Ab0GFQHw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jul 2010 12:07:52 -0400
Content-Disposition: inline
In-Reply-To: <20100706130203.GA31471@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 06, 2010 at 06:02:03AM -0700, Wu Fengguang wrote:
> The original KERN_CRIT will mess up terminals.

Looks reasonable to me.

Thanks,
Jon

>
> CC: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
>  drivers/net/vxge/vxge-main.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.c
> index 45c5dc2..93a9147 100644
> --- a/drivers/net/vxge/vxge-main.c
> +++ b/drivers/net/vxge/vxge-main.c
> @@ -4515,9 +4515,9 @@ vxge_starter(void)
>       char version[32];
>       snprintf(version, 32, "%s", DRV_VERSION);
>
> -     printk(KERN_CRIT "%s: Copyright(c) 2002-2009 Neterion Inc\n",
> +     printk(KERN_INFO "%s: Copyright(c) 2002-2009 Neterion Inc\n",
>               VXGE_DRIVER_NAME);
> -     printk(KERN_CRIT "%s: Driver version: %s\n",
> +     printk(KERN_INFO "%s: Driver version: %s\n",
>                       VXGE_DRIVER_NAME, version);
>
>       verify_bandwidth();
> --
> 1.6.6
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

The information and any attached documents contained in this message
may be confidential and/or legally privileged.  The message is
intended solely for the addressee(s).  If you are not the intended
recipient, you are hereby notified that any use, dissemination, or
reproduction is strictly prohibited and may be unlawful.  If you are
not the intended recipient, please contact the sender immediately by
return e-mail and destroy all copies of the original message.
