From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] virtio_net: rename driver struct to please modpost
Date: Thu, 05 Nov 2009 01:32:55 -0800 (PST)
Message-ID: <20091105.013255.27277499.davem@davemloft.net>
References: <200911051510.54163.rusty@rustcorp.com.au>
	<1257409037-29916-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mst@redhat.com, rusty@rustcorp.com.au, sam@ravnborg.org,
	alex.williamson@hp.com, markmc@redhat.com, netdev@vger.kernel.org
To: u.kleine-koenig@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58428
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750848AbZKEJca convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Nov 2009 04:32:30 -0500
In-Reply-To: <1257409037-29916-1-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
Date: Thu,  5 Nov 2009 09:17:17 +0100

> Commit
>=20
> 	3d1285b (move virtnet_remove to .devexit.text)
>=20
> introduced the first reference to __devexit in struct virtio_driver
> virtio_net which upset modpost ("Section mismatch in reference from t=
he
> variable virtio_net to the function .devexit.text:virtnet_remove()").
>=20
> Fix this by renaming virtio_net to virtio_net_driver.
>=20
> Signed-off-by: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
> Reported-by: Michael S. Tsirkin <mst@redhat.com>
> Blame-taken-by: Rusty Russell <rusty@rustcorp.com.au>

Applied, thanks.
