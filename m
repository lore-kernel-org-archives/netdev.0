From: Bill Fink <billfink@mindspring.com>
Subject: Re: [PATCH] net: Fix some fallout from the etner_addr_copy()
 changes.
Date: Tue, 21 Jan 2014 23:23:31 -0500
Message-ID: <20140121232331.130f34fc.billfink@mindspring.com>
References: <20140121.190348.1653034020095660800.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-curtail.atl.sa.earthlink.net ([209.86.89.64]:36902 "EHLO
	elasmtp-curtail.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752553AbaAVEYA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jan 2014 23:24:00 -0500
In-Reply-To: <20140121.190348.1653034020095660800.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 21 Jan 2014, David Miller wrote:

> net/appletalk/aarp.c: In function =E2=80=98__aarp_send_query=E2=80=99=
:
> net/appletalk/aarp.c:137:2: error: implicit declaration of function =E2=
=80=98ether_addr_copy=E2=80=99 [-Werror=3Dimplicit-function-declaration=
]
>  ...
> net/atm/lec.c: In function =E2=80=98send_to_lecd=E2=80=99:
> net/atm/lec.c:524:3: warning: passing argument 1 of =E2=80=98ether_ad=
dr_copy=E2=80=99 from incompatible pointer type [enabled by default]
> In file included from net/atm/lec.c:17:0:
> include/linux/etherdevice.h:227:20: note: expected =E2=80=98u8 *=E2=80=
=99 but argument is of type =E2=80=98unsigned char (*)[6]=E2=80=99
>  ...
> net/caif/caif_usb.c: In function =E2=80=98cfusbl_create=E2=80=99:
> net/caif/caif_usb.c:108:2: error: implicit declaration of function =E2=
=80=98ether_addr_copy=E2=80=99 [-Werror=3Dimplicit-function-declaration=
]
>=20
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  net/appletalk/aarp.c | 1 +
>  net/atm/lec.c        | 2 +-
>  2 files changed, 2 insertions(+), 1 deletion(-)

The commit message indicates problems with appletalk/aarp.c,
atm/lec.c, and caif/caif_usb.c, but the diffstat and patch only
address the first two and not caif/caif_usb.c.  Is that intended
or am I missing something.

					-Bill
