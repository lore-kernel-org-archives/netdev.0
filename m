From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 05/10] r6040: call napi_disable when puting down the interface
 and set lp->dev accordingly.
Date: Tue, 22 Jul 2008 20:00:25 -0400
Message-ID: <48867499.1040106@garzik.org>
References: <200807131432.46495.florian.fainelli@telecomint.eu> <20080716210138.GB27394@electric-eye.fr.zoreil.com> <200807211232.30809.florian.fainelli@telecomint.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
To: Florian Fainelli <florian.fainelli@telecomint.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:49797 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751390AbYGWAA3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jul 2008 20:00:29 -0400
In-Reply-To: <200807211232.30809.florian.fainelli@telecomint.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46lorian Fainelli wrote:
> Hi Francois,
>=20
> Le Wednesday 16 July 2008 23:01:38 Francois Romieu, vous avez =E9crit=
 :
>> Can you fix the error paths of r6040_init_one as well ?
>=20
> Patch attached below, are you okay with the other patches ?
>=20
> --
> From: Florian Fainelli <florian.fainelli@telecomint.eu>
> Subject: [PATCH] r6040: rework init_one error handling
>=20
> This patch reworks the error handling in r6040_init_one
> in order not to leak resources and correcly unmap and release
> PCI regions of the MAC. Also prefix printk's with the driver name
> for clarity.
>=20
> Signed-off-by: Florian Fainelli <florian.fainelli@telecomint.eu>

applied 5-10, plus this one


