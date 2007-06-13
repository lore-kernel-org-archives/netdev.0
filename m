From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [Cbe-oss-dev] [PATCH 12/15] spidernet: increase the NAPI weight
Date: Wed, 13 Jun 2007 22:49:51 +0200
Message-ID: <200706132249.51894.arnd@arndb.de>
References: <20070607191707.GA7904@austin.ibm.com> <20070611190236.GL13741@austin.ibm.com> <4670502C.5000506@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	Linas Vepstas <linas@austin.ibm.com>
To: cbe-oss-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.174]:63410 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752935AbXFMUuG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2007 16:50:06 -0400
In-Reply-To: <4670502C.5000506@garzik.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 13 June 2007, Jeff Garzik wrote:
> > +/* We really really want to empty the ring buffer every time,
> > + * so as to avoid the RX ram full bug. So set te napi wieght
> > + * to the ring size.
> > + */
> > +#define SPIDER_NET_NAPI_WEIGHT=A0=A0=A0=A0=A0=A0=A0SPIDER_NET_RX_D=
ESCRIPTORS_DEFAULT
>=20
> I don't see why spider_net should have a different NAPI weight from=20
> other drivers
>=20

Would it help to do it the other way round, as in

#define SPIDER_NET_RX_DESCRIPTORS_DEFAULT SPIDER_NET_NAPI_WEIGHT

and leave that at 64 instead of 256?

	Arnd <><
