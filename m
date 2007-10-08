From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH net-2.6.24] net: sparse warning fixes
Date: Mon, 8 Oct 2007 08:30:32 -0700
Message-ID: <20071008083032.6a842c00@freepuppy.rosehill>
References: <20071004201036.2665f6cc@freepuppy.rosehill>
	<20071005171407.19c65258@freepuppy.rosehill>
	<20071007.235956.98531097.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:36964 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750833AbXJHPaw convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Oct 2007 11:30:52 -0400
In-Reply-To: <20071007.235956.98531097.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 07 Oct 2007 23:59:56 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@linux-foundation.org>
> Date: Fri, 5 Oct 2007 17:14:07 -0700
>=20
> > Fix a bunch of sparse warnings. Mostly about 0 used as
> > NULL pointer, and shadowed variable declarations.
> >=20
> > The two noteable changes are:
> >  * hash size should have been unsigned
> >  * cls_u32 had a case where error code wasn't been
> >    propogated properly, so it could return 0 but still
> >    have an error.
> >=20
> > Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
>=20
> Applied, and I stuffed the cls_u32 fix into net-2.6 as well.
>=20
> But please fix the following, this is the second time I've
> had to remove this bit from one of your patches.
>=20
> > @@ -6,7 +6,7 @@
> >   *
> >   * Alexey Kuznetsov  <kuznet@ms2.inr.ac.ru>
> >   * Ben Greear <greearb@candelatech.com>
> > - * Jens L=C3=A5=C3=A5s <jens.laas@data.slu.se>
> > + * Jens L=C3=A5=C3=A5s <jens.laas@data.slu.se>
> >   *
> >   * This program is free software; you can redistribute it and/or
> >   * modify it under the terms of the GNU General Public License
>=20
> Please please please please, for the second time, fix the encoding
> your editor uses when you save copies of this source file, this hunk
> of your patches never applies cleanly.
>=20

It's either an Emacs or quilt problem. Probably emacs.

--=20
Stephen Hemminger <shemminger@linux-foundation.org>
