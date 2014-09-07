From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: mdio-sun4i: don't select REGULATOR
Date: Sun, 07 Sep 2014 16:12:30 -0700 (PDT)
Message-ID: <20140907.161230.1498704332590876012.davem@davemloft.net>
References: <1409956103-23473-1-git-send-email-b.galvani@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, maxime.ripard@free-electrons.com,
	arnd@arndb.de, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: b.galvani@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1409956103-23473-1-git-send-email-b.galvani@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Beniamino Galvani <b.galvani@gmail.com>
Date: Sat,  6 Sep 2014 00:28:23 +0200

> The mdio-sun4i driver automatically selects REGULATOR and
> REGULATOR_FIXED_VOLTAGE because it uses the regulator API. But a
> driver selecting a subsystem increases the chance of generating
> circular Kconfig dependencies, especially when other drivers depend on
> the selected symbol.
> 
> Since the regulator API functions are replaced with no-ops when
> REGULATOR is disabled, the driver can be built successfully even
> without regulator support and so those 'select' dependencies can be
> safely dropped.
> 
> Suggested-by: Arnd Bergmann <arnd@arndb.de>
> Signed-off-by: Beniamino Galvani <b.galvani@gmail.com>

Applied to net-next, thanks.
