From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH 4/4] m68k/atari: ARAnyM - Add support for network access
Date: Thu, 10 Feb 2011 09:37:41 +0100
Message-ID: <AANLkTi=j7X0LShJs6EVt0c_uE3vUvZ9EdGLwv7i43vx+@mail.gmail.com>
References: <1296989469-7844-1-git-send-email-geert@linux-m68k.org>
	<1296989469-7844-5-git-send-email-geert@linux-m68k.org>
	<20110206.111705.183051866.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-m68k@vger.kernel.org, linux-kernel@vger.kernel.org,
	aranym@lists.bobek.cz, schmitz@opal.biophys.uni-duesseldorf.de,
	pstehlik@sophics.cz, milan.jurik@xylab.cz, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <20110206.111705.183051866.davem@davemloft.net>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Feb 6, 2011 at 20:17, David Miller <davem@davemloft.net> wrote:
> From: Geert Uytterhoeven <geert@linux-m68k.org>
> Date: Sun, =C2=A06 Feb 2011 11:51:09 +0100
>
>> + =C2=A0 =C2=A0 dev->trans_start =3D jiffies;
>
> Device drivers no longer make this operation, the generic code
> does it (see net/core/dev.c:dev_hard_start_xmit() and how it
> invokes txq_trans_update() on ->ndo_start_xmit() success).
>
> Therefore, please remove this line.

Will do.

(180 more to go in drivers/net/?)

>> + =C2=A0 =C2=A0 pr_debug(DRV_NAME ": send %d bytes\n", len);
>
> For consistency with other network drivers, add an appropriate CPP
> define for "pr_fmt" and use netdev_info(), netdev_debug(), etc.
>
> In situations where a netdev pointer is not available
> (ie. pre-register_netdev()), use "dev_*()" instead.

Will fix.

Thanks for reviewing!

Gr{oetje,eeting}s,

=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-=
m68k.org

In personal conversations with technical people, I call myself a hacker=
=2E But
when I'm talking to journalists I just say "programmer" or something li=
ke that.
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0=C2=A0 =C2=A0=C2=A0 -- Linus Torvalds
