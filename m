From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [RFC PATCH] platform: Faciliatate the creation of
 pseduo-platform busses
Date: Wed, 4 Aug 2010 10:37:14 +0100
Message-ID: <20100804103714.48ddbe0e@lxorguk.ukuu.org.uk>
References: <4C58A7AA.8020007@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org,
	linux-omap.vger.kernel.org@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@suse.de>, damm@opensource.se,
	lethal@linux-sh.org, rjw@sisk.pl, dtor@mail.ru,
	eric.y.miao@gmail.com, netdev@vger.kernel.org
To: Patrick Pannuto <ppannuto@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4C58A7AA.8020007@codeaurora.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> 	(possibly in a header)
> 	#ifdef CONFIG_MY_BUS
> 	#define MY_BUS_TYPE	&my_bus_type
> 	#else
> 	#define MY_BUS_TYPE	NULL
> 	#endif
> 
> /drivers/my_driver.c
> 	static struct platform_driver my_driver = {
> 		.driver	= {
> 			.name	= "my-driver",
> 			.owner	= THIS_MODULE,
> 			.bus	= MY_BUS_TYPE,
> 		},
> 	};
> 
> Which will allow the same driver to easily to used on either
> the platform bus or the newly defined bus type.

At compile time. I suspect there is an argument for having an
"ANY_BUS_TYPE" value for the devices so that you can runtime wildcard
stuff which works whatever sub-bus it is hung off.

> I believe this to be a fairly elegant and simple solution to the
> problem, but humbly RFC

It's exactly what I need to tidy up the SCU IPC devices on the new Intel
MID platforms certainly. It's also a very small patch to achieve it

Alan
