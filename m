From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/core: split dev_ifsioc() according to locking
Date: Mon, 08 Oct 2007 00:06:53 -0700 (PDT)
Message-ID: <20071008.000653.51864134.davem@davemloft.net>
References: <20071006204212.GA32177@havoc.gtf.org>
	<200710070217.09073.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, akpm@linux-foundation.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58258
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752114AbXJHHGy convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Oct 2007 03:06:54 -0400
In-Reply-To: <200710070217.09073.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Arnd Bergmann <arnd@arndb.de>
Date: Sun, 7 Oct 2007 02:17:08 +0200

> On Saturday 06 October 2007, Jeff Garzik wrote:
> >=20
> > This always bugged me: =A0dev_ioctl() called dev_ifsioc() either in=
side
> > read_lock(dev_base_lock) or rtnl_lock(), depending on the ioctl bei=
ng
> > executed.
> >=20
> > This change moves the ioctls executed inside dev_base_lock to a new
> > function, dev_ifsioc_locked(). =A0Now the locking context is comple=
tely
> > clear to the reader.
> >=20
> > Signed-off-by: Jeff Garzik <jgarzik@redhat.com>
>=20
> Great idea!

I think so too, applied, thanks!
