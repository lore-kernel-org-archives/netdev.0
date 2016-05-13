From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH RFT 1/2] phylib: add device reset GPIO support
Date: Fri, 13 May 2016 23:56:12 +0300
Message-ID: <1a44a737-2b81-625b-8edf-d1c3dfcdd619@cogentembedded.com>
References: <81129033.NXiOLTg1so@wasted.cogentembedded.com>
 <3641492.klKRrvS8tr@wasted.cogentembedded.com>
 <20160512184233.GJ30822@pengutronix.de> <5735995B.8030802@ti.com>
 <b9bcc192-f97b-304e-77b2-894c4528ddb6@cogentembedded.com>
 <20160513204436.GC7600@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Roger Quadros <rogerq@ti.com>,
	=?UTF-8?Q?Uwe_Kleine-K=c3=b6nig?= <u.kleine-koenig@pengutronix.de>,
	grant.likely@linaro.org, robh+dt@kernel.org,
	devicetree@vger.kernel.org, f.fainelli@gmail.com,
	netdev@vger.kernel.org, frowand.list@gmail.com, pawel.moll@arm.com,
	mark.rutland@arm.com, ijc+devicetree@hellion.org.uk,
	galak@codeaurora.org, linux-kernel@vger.kernel.org,
	Linus Walleij <linus.walleij@linaro.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160513204436.GC7600@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/13/2016 11:44 PM, Andrew Lunn wrote:

>>> Another issue is that on some boards we have one reset line tied to
>>> multiple PHYs.How do we prevent multiple resets being taking place when each of
>>> the PHYs are registered?
>>
>>    My patch just doesn't address this case -- it's about the
>> individual resets only.
>
> This actually needs to be addresses a layer above. What you have is a
> bus reset, not a device reset.

    No.
    There's simply no such thing as a bus reset for the xMII/MDIO busses, 
there's simply no reset signaling on them. Every device has its own reset 
signal and its own timing requirements.

> So the gpio line is associated to the mdio bus, not a PHY.

    No.

> Either your MDIO driver needs to handle the gpio
> line,  or in __mdio_register(),

    __mdiobus_register(), you mean?

> before it starts looking at the
> children.

    It's basically the same thing.
    The MDIO bus reset is a misconception.

>
> 	Andrew

MBR, Sergei
