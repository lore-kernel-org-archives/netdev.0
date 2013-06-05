From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCHv2 1/3] net: phy: prevent linking breakage
Date: Wed, 5 Jun 2013 13:21:00 +0200
Message-ID: <201306051321.00264.arnd@arndb.de>
References: <1369741403-25315-2-git-send-email-alexandre.belloni@free-electrons.com> <CAGVrzcZcVB5+NqLop+ALrX4Jx_SyNatczLt4oNzXr7bjgKMXhg@mail.gmail.com> <51AF03AF.3080106@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <florian@openwrt.org>,
	linux-arm-kernel@lists.infradead.org,
	Russell King <linux@arm.linux.org.uk>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel <kernel@pengutronix.de>,
	"shawn.guo" <shawn.guo@linaro.org>,
	David Miller <davem@davemloft.net>,
	Nicolas Ferre <nicolas.ferre@atmel.com>
To: Alexandre Belloni <alexandre.belloni@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51AF03AF.3080106@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 05 June 2013, Alexandre Belloni wrote:
> However, it is becoming urgent for Atmel to get the fix in 3.10 so that
> they never get a kernel compilation that breaks.

I don't think it's urgent since this is only about rare configurations,
and not a regression. We can queue the patch "ARM: at91: Fix link
breakage when !CONFIG_PHYLIB" you just sent to fix this, but I
would not consider it a serious problem to have it only in 3.11.

	Arnd
