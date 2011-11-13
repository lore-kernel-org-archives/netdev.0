From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH 03/16] mac_sonic: add irq resources and cleanup
Date: Sun, 13 Nov 2011 11:28:49 +0100
Message-ID: <CAMuHMdUHbqqt9Rce=Mh5A0GB_BHJX21dBSggFcqb9q4omDuyBQ@mail.gmail.com>
References: <20111023141108.856998818@telegraphics.com.au>
	<20111023141124.538715283@telegraphics.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-m68k@vger.kernel.org, netdev@vger.kernel.org
To: Finn Thain <fthain@telegraphics.com.au>,
	David Miller <davem@davemloft.net>
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <20111023141124.538715283@telegraphics.com.au>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Oct 23, 2011 at 16:11, Finn Thain <fthain@telegraphics.com.au> =
wrote:
> Make better use of the SONIC platform device by adding irq resources.=
 This moves the via_type logic out of the NIC device driver which impro=
ves modularity.
>
> Since interrupt handlers now run with CPU interrupts disabled, we don=
't need the macsonic_interrupt() wrapper. Remove it.

Please wrap lines at 75, for easier to read "git log" output.

> For consistency, rename retval as err.
>
> Signed-off-by: Finn Thain <fthain@telegraphics.com.au>

David: Is it OK for this patch to go in through the m68k tree, as it to=
uches
core m68k files?

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
