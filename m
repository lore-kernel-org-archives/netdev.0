From: Paulius Zaleckas <paulius.zaleckas@gmail.com>
Subject: Re: [RFC PATCH 1/2] Gemini: create platform device for ethernet in
 Raidsonic IB-4220B
Date: Fri, 29 Oct 2010 14:17:07 +0300
Message-ID: <AANLkTik+r8r-pywpFYfwrZX2bTjgAVd1rwvoTi7ttq3B@mail.gmail.com>
References: <cover.1288321597.git.mirq-linux@rere.qmqm.pl>
	<181be0f834f3670249d3c8d7ba1462dab1ece2c1.1288321597.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hans Ulli Kroll <ulli.kroll@googlemail.com>,
	Russell King <linux@arm.linux.org.uk>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Janos Laube <janos.dev@gmail.com>
To: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <181be0f834f3670249d3c8d7ba1462dab1ece2c1.1288321597.git.mirq-linux@rere.qmqm.pl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2010/10/29 Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>:
> This is cherry-picked from:
>
> git://git.berlios.de/gemini-board ib4220
>
> Code by Paulius Zaleckas <paulius.zaleckas@gmail.com>
> and Janos Laube <janos.dev@gmail.com>.
>
> Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
> ---
>
> =C2=A0arch/arm/mach-gemini/board-nas4220b.c =C2=A0 =C2=A0| =C2=A0 53 =
++++++++++++++++++++++++++++++
> =C2=A0arch/arm/mach-gemini/common.h =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0| =C2=A0 =C2=A02 +
> =C2=A0arch/arm/mach-gemini/devices.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 | =C2=A0 52 +++++++++++++++++++++++++++++
> =C2=A0arch/arm/mach-gemini/include/mach/gmac.h | =C2=A0 21 ++++++++++=
++
> =C2=A04 files changed, 128 insertions(+), 0 deletions(-)
> =C2=A0create mode 100644 arch/arm/mach-gemini/include/mach/gmac.h
>
[...]
> diff --git a/arch/arm/mach-gemini/include/mach/gmac.h b/arch/arm/mach=
-gemini/include/mach/gmac.h
> new file mode 100644
> index 0000000..c6eeacc
> --- /dev/null
> +++ b/arch/arm/mach-gemini/include/mach/gmac.h
> @@ -0,0 +1,21 @@
> +/*
> + * Gemini GMAC specific defines
> + *
> + * Copyright (C) 2008, Paulius Zaleckas <paulius.zaleckas@teltonika.=
lt>

This e-mail is dead. Please change it to gmail one.

> + *
> + * This program is free software; you can redistribute it and/or mod=
ify
> + * it under the terms of the GNU General Public License as published=
 by
> + * the Free Software Foundation; either version 2 of the License, or
> + * (at your option) any later version.
> + */
> +#ifndef __MACH_GMAC_H__
> +#define __MACH_GMAC_H__
> +
> +#include <linux/phy.h>
> +
> +struct gemini_gmac_platform_data {
> + =C2=A0 =C2=A0 =C2=A0 char *bus_id[2]; /* NULL means that this port =
is not used */
> + =C2=A0 =C2=A0 =C2=A0 phy_interface_t interface[2];
> +};
> +
> +#endif /* __MACH_GMAC_H__ */
> --
> 1.7.1
>
>
