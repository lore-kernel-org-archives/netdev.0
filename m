From: Zubair Lutfullah Kakakhel <Zubair.Kakakhel-1AXoQHu6uovQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] dm9000: Add regulator and reset support to dm9000
Date: Tue, 16 Dec 2014 16:41:29 +0000
Message-ID: <549060B9.6060506@imgtec.com>
References: <1418747624-2682-1-git-send-email-Zubair.Kakakhel@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <paul.burton-1AXoQHu6uovQT0dZR+AlfA@public.gmane.org>
To: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1418747624-2682-1-git-send-email-Zubair.Kakakhel-1AXoQHu6uovQT0dZR+AlfA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On 16/12/14 16:33, Zubair Lutfullah Kakakhel wrote:
...

> +
> +	power = devm_regulator_get(dev, "vcc");
> +	if (IS_ERR(power)) {
> +		dev_dbg(dev, "no regulator provided\n");
> +	} else if (!regulator_is_enabled(power)) {
> +		ret = regulator_enable(power);
> +		dev_dgb(dev, "regulator enabled\n");
		^dev_dbg

Apologies. This fix wasn't squashed in. I'll resend.

> +	}
> +
> +	reset_gpio = of_get_named_gpio_flags(dev->of_node, "reset-gpio", 0,
> +					     &flags);

ZubairLK
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
