From: Stefan Roese <sr@denx.de>
Subject: Re: [PATCH] net: sun4i-emac: remove erroneous assignment
Date: Tue, 04 Jun 2013 07:52:37 +0200
Message-ID: <51AD80A5.20308@denx.de>
References: <3298610.K0DeJZEM4E@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Maxime Ripard <maxime.ripard@free-electrons.com>,
	Richard Genoud <richard.genoud@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <3298610.K0DeJZEM4E@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/03/2013 11:36 PM, Arnd Bergmann wrote:
> The newly added sun4i-emac driver causes a build error when
> CONFIG_NET_POLL_CONTROLLER is set, because it attempts to
> assign a pointer to netdev->poll_controller, which has
> been replaced with ops->ndo_poll_controller in 2.6.31!
> 
> The correct assignment is present as well, so we just need
> to remove the wrong one.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Cc: Stefan Roese <sr@denx.de>
> Cc: Maxime Ripard <maxime.ripard@free-electrons.com>
> Cc: Richard Genoud <richard.genoud@gmail.com>

Thanks for fixing this:

Acked-by: Stefan Roese <sr@denx.de>

Thanks,
Stefan
