From: Andrew Bresticker <abrestic-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH V2 2/2] stmmac: Add IMG Pistachio platform glue layer
Date: Mon, 6 Apr 2015 15:27:31 -0700
Message-ID: <CAL1qeaFwt-VB6rUywHZ47gOx4fhd6LZLfvwqkydOtqWLkYbO8A@mail.gmail.com>
References: <1428356558-18367-1-git-send-email-abrestic@chromium.org>
	<1428356558-18367-2-git-send-email-abrestic@chromium.org>
	<2916148.ZqFzHAuDtr@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Govindraj Raja <govindraj.raja-1AXoQHu6uovQT0dZR+AlfA@public.gmane.org>
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	James Hartley <james.hartley-1AXoQHu6uovQT0dZR+AlfA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <2916148.ZqFzHAuDtr@wuerfel>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 6, 2015 at 3:10 PM, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org> wrote:
> On Monday 06 April 2015 14:42:38 Andrew Bresticker wrote:
>> At the moment, the only additional setup required for the DWMAC
>> on the IMG Pistachio SoC is to request and enable a separate gate
>> clock for the register interface.
>>
>> Signed-off-by: Andrew Bresticker <abrestic-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
>> Signed-off-by: Govindraj Raja <govindraj.raja-1AXoQHu6uovQT0dZR+AlfA@public.gmane.org>
>> Cc: James Hartley <james.hartley-1AXoQHu6uovQT0dZR+AlfA@public.gmane.org>
>
> Why do you need a special glue driver for that?
>
> Since you don't do anything special, I'd say it should be possible
> to handle this with just the default driver.

Right, at the moment we only need to request and enable a second
clock, which could be added to the core driver.  If we don't expect to
have to extend this driver to deal with other configurations (which
IIRC there were some concerns about when I wrote this), then I'm fine
with folding this change into the core driver - James?

Thanks,
Andrew
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
