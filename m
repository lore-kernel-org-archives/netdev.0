From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [PATCH 2/4] net: smsc911x: add a reset GPIO DT binding
Date: Wed, 24 Jul 2013 00:18:08 +0200
Message-ID: <20130723221808.GA7727@pengutronix.de>
References: <1374595924-12338-1-git-send-email-g.liakhovetski@gmx.de>
 <1374595924-12338-3-git-send-email-g.liakhovetski@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-sh@vger.kernel.org, Magnus Damm <magnus.damm@gmail.com>,
	Simon Horman <horms@verge.net.au>,
	Steve Glendinning <steve.glendinning@shawell.net>,
	netdev@vger.kernel.org,
	Guennadi Liakhovetski <g.liakhovetski+renesas@gmail.com>,
	devicetree@vger.kernel.org
To: Guennadi Liakhovetski <g.liakhovetski@gmx.de>
Return-path: <linux-sh-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1374595924-12338-3-git-send-email-g.liakhovetski@gmx.de>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 23, 2013 at 06:12:02PM +0200, Guennadi Liakhovetski wrote:
> Add a new DT property to specify a reset GPIO.
> 
> Signed-off-by: Guennadi Liakhovetski <g.liakhovetski+renesas@gmail.com>
> Cc: devicetree@vger.kernel.org
> ---
>  Documentation/devicetree/bindings/net/smsc911x.txt |    1 +
>  drivers/net/ethernet/smsc/smsc911x.c               |   11 +++++++++++
>  2 files changed, 12 insertions(+), 0 deletions(-)
> 
> diff --git a/Documentation/devicetree/bindings/net/smsc911x.txt b/Documentation/devicetree/bindings/net/smsc911x.txt
> index adb5b57..2bf32be 100644
> --- a/Documentation/devicetree/bindings/net/smsc911x.txt
> +++ b/Documentation/devicetree/bindings/net/smsc911x.txt
> @@ -23,6 +23,7 @@ Optional properties:
>    external PHY
>  - smsc,save-mac-address : Indicates that mac address needs to be saved
>    before resetting the controller
> +- smsc,reset-gpios : a GPIO binding to take the controller out of reset
>  - local-mac-address : 6 bytes, mac address

BTW there's also:

[PATCH v10] reset: Add driver for gpio-controlled reset pins

http://www.mail-archive.com/devicetree-discuss@lists.ozlabs.org/msg36900.html

which may be a generic way to handle device resets. Not mainline yet,
though.

Sascha

-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
