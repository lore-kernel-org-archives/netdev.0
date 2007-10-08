From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.24] net: sparse warning fixes
Date: Sun, 07 Oct 2007 23:59:56 -0700 (PDT)
Message-ID: <20071007.235956.98531097.davem@davemloft.net>
References: <20071004201036.2665f6cc@freepuppy.rosehill>
	<20071005171407.19c65258@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46933
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752675AbXJHG75 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Oct 2007 02:59:57 -0400
In-Reply-To: <20071005171407.19c65258@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Fri, 5 Oct 2007 17:14:07 -0700

> Fix a bunch of sparse warnings. Mostly about 0 used as
> NULL pointer, and shadowed variable declarations.
>=20
> The two noteable changes are:
>  * hash size should have been unsigned
>  * cls_u32 had a case where error code wasn't been
>    propogated properly, so it could return 0 but still
>    have an error.
>=20
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

Applied, and I stuffed the cls_u32 fix into net-2.6 as well.

But please fix the following, this is the second time I've
had to remove this bit from one of your patches.

> @@ -6,7 +6,7 @@
>   *
>   * Alexey Kuznetsov  <kuznet@ms2.inr.ac.ru>
>   * Ben Greear <greearb@candelatech.com>
> - * Jens L=E5=E5s <jens.laas@data.slu.se>
> + * Jens L=E5=E5s <jens.laas@data.slu.se>
>   *
>   * This program is free software; you can redistribute it and/or
>   * modify it under the terms of the GNU General Public License

Please please please please, for the second time, fix the encoding
your editor uses when you save copies of this source file, this hunk
of your patches never applies cleanly.

Thanks.
