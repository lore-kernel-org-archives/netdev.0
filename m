From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] convert sis900 to new style parameters
Date: Sat, 13 Nov 2004 20:19:52 -0500
Message-ID: <4196B2B8.3040202@pobox.com>
References: <20041112220710.GB29980@gateway.milesteg.arr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>, NetDev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Daniele Venzano <webvenza@libero.it>
In-Reply-To: <20041112220710.GB29980@gateway.milesteg.arr>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Patch is OK, but your mailer sends them "MIME-encrypted", which means 
script (like the ones I use) cannot merge the patch.

Example from your email:
> @@ -179,9 +180,9 @@
>  MODULE_DESCRIPTION("SiS 900 PCI Fast Ethernet driver");
>  MODULE_LICENSE("GPL");
> =20
> -MODULE_PARM(multicast_filter_limit, "i");
> -MODULE_PARM(max_interrupt_work, "i");
> -MODULE_PARM(debug, "i"); 
> +module_param(multicast_filter_limit, int, 0444);
> +module_param(max_interrupt_work, int, 0444);
> +module_param(debug, int, 0444);
>  MODULE_PARM_DESC(multicast_filter_limit, "SiS 900/7016 maximum number of f=
> iltered multicast addresses");
>  MODULE_PARM_DESC(max_interrupt_work, "SiS 900/7016 maximum events handled =
> per interrupt");
>  MODULE_PARM_DESC(debug, "SiS 900/7016 debug level (2-4)");
