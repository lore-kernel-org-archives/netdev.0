From: David Miller <davem@davemloft.net>
Subject: Re: Broken rndis_host with #define DEBUG (by
 a475f603d23392f386e45cf377b17c30ed3bbb80)
Date: Wed, 16 Jun 2010 18:11:45 -0700 (PDT)
Message-ID: <20100616.181145.02276685.davem@davemloft.net>
References: <1276377038.21640.67.camel@Joe-Laptop.home>
	<299618.58880.qm@web180304.mail.gq1.yahoo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jussi.kivilinna@mbnet.fi, joe@perches.com, netdev@vger.kernel.org,
	dbrownell@users.sourceforge.net
To: david-b@pacbell.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57017
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754847Ab0FQBLf convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jun 2010 21:11:35 -0400
In-Reply-To: <299618.58880.qm@web180304.mail.gq1.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: David Brownell <david-b@pacbell.net>
Date: Sat, 12 Jun 2010 19:49:27 -0700 (PDT)

> --- On Sat, 6/12/10, Joe Perches <joe@perches.com> wrote:
>=20
>> > rndis_host oopses with #define DEBUG, in
>> generic_rndis_bind() when=A0=20
>> > calling netif_dbg(). Problem is that
>> (netdev)->dev.parent is NULL
>=20
>> > (used in netdev_printk) while generic_rndis_bind is
>> called.Thanks.
>=20
> Should have been assigned by SET_NETDEV_DEV()
> in usbnet_probe() ... before calling the
> bind() routine
>=20
> Maybe just moving that SET_NETDEV_DEV earlier
> would suffice.

Can someone please submit a patch which does this?

Thanks!
