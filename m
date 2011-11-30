From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH] can: Update logging style
Date: Wed, 30 Nov 2011 14:43:58 +0100
Message-ID: <4ED6331E.6020005@hartkopp.net>
References: <30551d0a6a0f7f7799a6981c81c770a528f430d2.1322592708.git.joe@perches.com> <4ED53B47.1030703@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Joe Perches <joe@perches.com>,
	Urs Thuermann <urs.thuermann@volkswagen.de>,
	"David S. Miller" <davem@davemloft.net>, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4ED53B47.1030703@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 29.11.2011 21:06, Marc Kleine-Budde wrote:

> On 11/29/2011 07:54 PM, Joe Perches wrote:
>> Use pr_fmt, pr_<level> and pr_<level>_ratelimited.
>> Coalesce format strings.
>>
>> Signed-off-by: Joe Perches <joe@perches.com>
> 
> The banners will probably looking a bit different, but I think nobody is
> screen scraping that output :)
> 
> Acked-by: Marc Kleine-Budde <mkl@pengutronix.de>



Nobody but me. Therefore it get's a NACK.

Indeed the banners are pretty broken now ...

Before:

can: controller area network core (rev 20090105 abi 8)
NET: Registered protocol family 29
can: raw protocol (rev 20090105)
can: netlink gateway (rev 20101209)
can: broadcast manager protocol (rev 20090105 t)

After Joe's patch:

can: controller area network core (rev 20090105 abi 8)
NET: Registered protocol family 29
can_raw: raw protocol (rev 20090105)
can_gw: netlink gateway (rev 20101209)
can_bcm: broadcast manager protocol (rev 20090105 t)

IMO if you want to use pr_fmt() it should at least look like this:

can: controller area network core (rev 20090105 abi 8)
NET: Registered protocol family 29
can_raw: can raw protocol (rev 20090105)
can_gw: can netlink gateway (rev 20101209)
can_bcm: can broadcast manager protocol (rev 20090105 t)

I'm fine with using pr_fmt() for error/warning output but not for the banner
in the currently suggested way.

Regards,
Oliver
