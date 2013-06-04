From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCHv2 1/3] net: phy: prevent linking breakage
Date: Tue, 04 Jun 2013 19:17:59 +0200
Message-ID: <10306449.AbS8Q0UukT@wuerfel>
References: <1369741403-25315-2-git-send-email-alexandre.belloni@free-electrons.com> <1394174.ONngHnHYKL@wuerfel> <CAGVrzcZcVB5+NqLop+ALrX4Jx_SyNatczLt4oNzXr7bjgKMXhg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-arm-kernel@lists.infradead.org,
	Russell King <linux@arm.linux.org.uk>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"alexandre.belloni" <alexandre.belloni@free-electrons.com>,
	kernel <kernel@pengutronix.de>,
	"shawn.guo" <shawn.guo@linaro.org>,
	David Miller <davem@davemloft.net>
To: Florian Fainelli <florian@openwrt.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGVrzcZcVB5+NqLop+ALrX4Jx_SyNatczLt4oNzXr7bjgKMXhg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 04 June 2013 17:09:26 Florian Fainelli wrote:
> You would just need to define a stub for your arch_foo_phy_fixup()
> which has a different definition depending on whether CONFIG_PHYLIB is
> defined or not.

Yes, same thing. For a function that is called in only one place,
I would always prefer if(IS_ENABLED()) over a stub though.

> This would be just one function, instead of the whole bunch of stubs
> needed for phylib. Right now its probably 1 vs 3, so it does not make
> that much of a difference but who knows, if we had more phylib stubs
> and forget to update the stubs? (which tends to happen pretty often).
> 
> The size savings are exactly the same in both approaches anyway.

So should we just stick to the current method then and use
if (IS_ENABLED(CONFIG_NET)) for calling the function?

	Arnd
