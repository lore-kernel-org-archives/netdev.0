From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] net-2.6.24: move hardware header operations out of
 netdevice
Date: Wed, 26 Sep 2007 22:20:45 -0700 (PDT)
Message-ID: <20070926.222045.91776503.davem@davemloft.net>
References: <20070925.192428.18597166.davem@davemloft.net>
	<20070926172129.5550a636@freepuppy.rosehill>
	<20070926172246.0425e232@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53277
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751763AbXI0FUp convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Sep 2007 01:20:45 -0400
In-Reply-To: <20070926172246.0425e232@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Wed, 26 Sep 2007 17:22:46 -0700

> Since hardware header operations are part of the protocol class
> not the device instance, make them into a separate object and
> save memory.
>=20
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

I applied this by hand since there were conflicts with Eric B.'s
round of network namespace patches from today which I applied
first.

Also:

> --- a/drivers/net/hamradio/6pack.c	2007-09-26 15:07:23.000000000 -070=
0
> +++ b/drivers/net/hamradio/6pack.c	2007-09-26 16:41:09.000000000 -070=
0
> @@ -3,7 +3,7 @@
>   *		devices like TTY. It interfaces between a raw TTY and the
>   *		kernel's AX.25 protocol layers.
>   *
> - * Authors:	Andreas K=F6nsgen <ajk@iehk.rwth-aachen.de>
> + * Authors:	Andreas K=F6nsgen <ajk@iehk.rwth-aachen.de>
>   *              Ralf Baechle DL5RB <ralf@linux-mips.org>
>   *
>   * Quite a lot of stuff "stolen" by Joerg Reuter from slip.c, writte=
n by

This hunk rejected and I therefore left it out.

Whatever editor you used aparently tried to change the character set
encoding or something silly like that.
