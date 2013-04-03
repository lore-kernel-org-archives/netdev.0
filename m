From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v5 2/6] usb: phy: omap-usb2: use the new generic PHY framework
Date: Wed, 3 Apr 2013 14:55:47 +0000
Message-ID: <201304031455.47864.arnd@arndb.de>
References: <1364993634-6378-1-git-send-email-kishon@ti.com> <1364993634-6378-3-git-send-email-kishon@ti.com> <20130403134827.GF14680@arwen.pp.htv.fi>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Kishon Vijay Abraham I <kishon@ti.com>, gregkh@linuxfoundation.org,
	akpm@linux-foundation.org, swarren@wwwdotorg.org,
	sylvester.nawrocki@gmail.com, rob@landley.net,
	netdev@vger.kernel.org, davem@davemloft.net, cesarb@cesarb.net,
	linux-usb@vger.kernel.org, linux-omap@vger.kernel.org,
	linux-kernel@vger.kernel.org, tony@atomide.com,
	grant.likely@secretlab.ca, rob.herring@calxeda.com,
	b-cousson@ti.com, linux@arm.linux.org.uk, eballetbo@gmail.com,
	javier@dowhile0.org, mchehab@redhat.com, santosh.shilimkar@ti.com,
	broonie@opensource.wolfsonmicro.com, swarren@nvidia.com,
	linux-doc@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	linux-arm-kernel@lists.infradead.org
To: balbi@ti.com
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20130403134827.GF14680@arwen.pp.htv.fi>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 03 April 2013, Felipe Balbi wrote:
> const ? Maybe provide a:
> 
> #define DEFINE_PHY_OPS(name)    \
> const struct phy_ops #name_phy_ops = {
> 
> macro ? This will force people to add the const keyword :-)

Forcing people to use const structures is good, but I think it would be
better without the macro, just by marking the argument in 
devm_phy_create() as const.

	Arnd
