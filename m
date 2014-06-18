From: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>
Subject: Re: [PATCH net-next v2 1/3] ieee802154: cc2520: adds driver for TI
 CC2520 radio
Date: Wed, 18 Jun 2014 10:55:19 +0100
Message-ID: <20140618095519.GE26461@leverpostej>
References: <1403068565-32224-1-git-send-email-varkab@cdac.in>
 <1403068565-32224-2-git-send-email-varkab@cdac.in>
 <20140618091010.GB26461@leverpostej>
 <53A15B38.6060404@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org"
	<linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Varka Bhadram <varkab-If5XQcfNmg0@public.gmane.org>
To: Varka Bhadram <varkabhadram-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <53A15B38.6060404-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 18, 2014 at 10:26:16AM +0100, Varka Bhadram wrote:
> +static int cc2520_probe(struct spi_device *spi)
> +{
> +       struct cc2520_private *priv;
> +       struct pinctrl *pinctrl;
> +       struct cc2520_platform_data *pdata;
> +       struct device_node __maybe_unused *np = spi->dev.of_node;
> 
> This looks to be definitely unused rather than __maybe_unused. There are
> no other occuences of "np" in this function.
> 
> This macro defined like this.
> #define __maybe_unused  __attribute__((unused))

Sure, but that's irrelevant. There's absolutely no point in this
variable existing at all, and it can simply disappear.

Mark.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
