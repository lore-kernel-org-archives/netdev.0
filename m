From: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH RFT 1/2] phylib: add device reset GPIO support
Date: Thu, 19 May 2016 16:40:06 +0300
Message-ID: <9d09a39b-de72-1148-4b5d-6cfaee8da604@cogentembedded.com>
References: <3641492.klKRrvS8tr@wasted.cogentembedded.com>
 <20160512184233.GJ30822@pengutronix.de> <5735995B.8030802@ti.com>
 <b9bcc192-f97b-304e-77b2-894c4528ddb6@cogentembedded.com>
 <20160513204436.GC7600@lunn.ch>
 <1a44a737-2b81-625b-8edf-d1c3dfcdd619@cogentembedded.com>
 <20160513234410.GE7600@lunn.ch>
 <cc232c9e-ef25-482d-0978-cbdfe03bad22@cogentembedded.com>
 <20160514195016.GC26220@lunn.ch>
 <34922ff9-e566-4829-a631-54ce07cbb325@cogentembedded.com>
 <20160515152339.GA9021@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Roger Quadros <rogerq-l0cyMroinI0@public.gmane.org>,
	=?UTF-8?Q?Uwe_Kleine-K=c3=b6nig?= <u.kleine-koenig-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, frowand.list-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, pawel.moll-5wv7dgnIgG8@public.gmane.org,
	mark.rutland-5wv7dgnIgG8@public.gmane.org, ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org,
	galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
To: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160515152339.GA9021-g2DYL2Zd6BY@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello.

On 5/15/2016 6:23 PM, Andrew Lunn wrote:

>>> I think there could be similar code one layer above to handle one gpio
>>> line for multiple phys.
>>
>>    Ah, you want me to recognize some MAC/MDIO bound prop (e.g.
>> "mdio-reset-gpios") in of_mdiobus_register()? I'll think about it
>> now that my patch needs fixing anyway...
>
> Hi Sergi
>
> It does not need to be you implementing this, your hardware does not
> need it. However, if you do feel like doing it, great.

    It would cover my "single PHY" case anyway.

>      Andrew

MBR, Sergei

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
