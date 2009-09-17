From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] ks8851_ml ethernet network driver
Date: Thu, 17 Sep 2009 06:03:15 -0700
Message-ID: <20090917130315.GA4157@kroah.com>
References: <20090917023836.GA15260@kroah.com> <20090916.204801.190052862.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Charles.Li@Micrel.Com, Choi@kroah.com,
	David.Choi@Micrel.Com, jgarzik@redhat.com, shemminger@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:37951 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753224AbZIQNEK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2009 09:04:10 -0400
Content-Disposition: inline
In-Reply-To: <20090916.204801.190052862.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 16, 2009 at 08:48:01PM -0700, David Miller wrote:
> From: Greg KH <greg@kroah.com>
> Date: Wed, 16 Sep 2009 19:38:36 -0700
>=20
> > From: Choi, David <David.Choi@Micrel.Com>
> >=20
> > This is a network driver for the ks8851 16bit MLL ethernet device.
> >=20
> > Signed-off-by: David J. Choi <david.choi@micrel.com>
> > Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>
>=20
> This doesn't even build cleanly:
>=20
> drivers/net/ks8851_mll.c: In function =E2=80=98ks_inblk=E2=80=99:
> drivers/net/ks8851_mll.c:555: warning: cast from pointer to integer o=
f different size
> drivers/net/ks8851_mll.c:558: warning: passing argument 1 of =E2=80=98=
_readw=E2=80=99 makes pointer from integer without a cast
> drivers/net/ks8851_mll.c: In function =E2=80=98ks_outblk=E2=80=99:
> drivers/net/ks8851_mll.c:571: warning: cast from pointer to integer o=
f different size
> drivers/net/ks8851_mll.c:574: warning: passing argument 2 of =E2=80=98=
_writew=E2=80=99 makes pointer from integer without a cast

Ick, David Choi, what happened here?

> It also has a big "#define DEBUG" at the beginning of the driver.
>=20
> And it also has stuff like:
>=20
> +#define MALLOC(x)		kmalloc(x, GFP_KERNEL)
>=20
> which actually decreases the readability of this driver.
>=20
> Please fix this up.

Sorry about that, I'll do a closer review next time before resubmitting=
=2E

David Choi, care to fix this, and the comments from Stephen up?

thanks,

greg k-h
