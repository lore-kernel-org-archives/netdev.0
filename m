From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH] Revert "phy: add support for a reset-gpio specification"
Date: Wed, 18 May 2016 12:54:07 -0700
Message-ID: <20160518195407.GA23997@roeck-us.net>
References: <1463587500-12293-1-git-send-email-fabio.estevam@nxp.com>
 <573C9DC6.9010700@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Fabio Estevam <fabio.estevam@nxp.com>, davem@davemloft.net,
	u.kleine-koenig@pengutronix.de, netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:44995 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752299AbcERTyK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2016 15:54:10 -0400
Content-Disposition: inline
In-Reply-To: <573C9DC6.9010700@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 18, 2016 at 09:52:22AM -0700, Florian Fainelli wrote:
> On 05/18/2016 09:05 AM, Fabio Estevam wrote:
> > Commit da47b4572056 ("phy: add support for a reset-gpio specification")
> > causes the following xtensa qemu crash according to Guenter Roeck:
> > 
> > [    9.366256] libphy: ethoc-mdio: probed
> > [    9.367389]  (null): could not attach to PHY
> > [    9.368555]  (null): failed to probe MDIO bus
> > [    9.371540] Unable to handle kernel paging request at virtual address 0000001c
> > [    9.371540]  pc = d0320926, ra = 903209d1
> > [    9.375358] Oops: sig: 11 [#1]
> > 
> > This reverts commit da47b4572056487fd7941c26f73b3e8815ff712a.
> > 
> > Reported-by: Guenter Roeck <linux@roeck-us.net>
> > Signed-off-by: Fabio Estevam <fabio.estevam@nxp.com>
> 
> Acked-by: Florian Fainelli <f.fainelli@gmail.com>
> 
Tested-by: Guenter Roeck <linux@roeck-us.net>
