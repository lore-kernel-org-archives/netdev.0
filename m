From: "Andrew F. Davis" <afd-l0cyMroinI0@public.gmane.org>
Subject: Re: [PATCH v2 net-next] net: ethernet: enc28j60: add device tree
 support
Date: Mon, 25 Apr 2016 13:04:56 -0500
Message-ID: <571E5C48.6030001@ti.com>
References: <31567588.rB9VrggOb6@wuerfel>
 <1461533283-24852-1-git-send-email-mhei@heimpold.de>
 <571E3A3D.5080602@ti.com> <7030050.tME0DkDS0E@kerker>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Jonathan Cameron <jic23-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Mark Brown <broonie-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Pawel Moll <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
	Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	Ian Campbell <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>,
	Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
To: Michael Heimpold <mhei-Z/Lg1yOAjpkb1SvskN2V4Q@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <7030050.tME0DkDS0E@kerker>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 04/25/2016 12:46 PM, Michael Heimpold wrote:
> Hi,
> 
> Am Monday 25 April 2016, 10:39:41 schrieben Sie:
>> On 04/24/2016 04:28 PM, Michael Heimpold wrote:
>>> -	eth_hw_addr_random(dev);
>>> +
>>> +	macaddr = of_get_mac_address(spi->dev.of_node);
>>> +	if (macaddr)
>>
>> You should also check if it is a valid MAC for Ethernet, recommend:
>>
>> if (macaddr && is_valid_ether_addr(macaddr))
>>
> 
> But of_get_mac_address already takes care of this, see
> http://lxr.free-electrons.com/source/drivers/of/of_net.c#L45
> Also it already checks whether spi->dev.of_node is populated at all.
> It returns NULL in both error cases.
> So I prefered to omit both test here.
> 

Ah, missed that, no problem here then.

Hmm, I wonder how many other drivers then do this check needlessly..
Time to fire-up Coccinelle :)

Andrew
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
