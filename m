From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [RFC 43/72] a2065/ariadne: Move the a2065/ariadne drivers
Date: Tue, 28 Jun 2011 22:33:58 +0200
Message-ID: <BANLkTin_SRhrd4dnfBH48b1aTikw5-mjtg@mail.gmail.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1309010363-22750-44-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:61783 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750708Ab1F1UeB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2011 16:34:01 -0400
Received: by iyb12 with SMTP id 12so469234iyb.19
        for <netdev@vger.kernel.org>; Tue, 28 Jun 2011 13:34:00 -0700 (PDT)
In-Reply-To: <1309010363-22750-44-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 25, 2011 at 15:58, Jeff Kirsher <jeffrey.t.kirsher@intel.co=
m> wrote:
> --- a/drivers/net/ethernet/Kconfig
> +++ b/drivers/net/ethernet/Kconfig
> @@ -12,8 +12,31 @@ menuconfig ETHERNET
> =C2=A0if ETHERNET
>
> =C2=A0source "drivers/net/ethernet/3com/Kconfig"
> +
> +config A2065
> + =C2=A0 =C2=A0 =C2=A0 tristate "A2065 support"
> + =C2=A0 =C2=A0 =C2=A0 depends on ZORRO
> + =C2=A0 =C2=A0 =C2=A0 select CRC32
> + =C2=A0 =C2=A0 =C2=A0 ---help---
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 If you have a Commodore A2065 Ethernet =
adapter, say Y. Otherwise,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 say N.
> +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 To compile this driver as a module, cho=
ose M here: the module
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 will be called a2065.
> +
> =C2=A0source "drivers/net/ethernet/amd/Kconfig"
> =C2=A0source "drivers/net/ethernet/apple/Kconfig"
> +
> +config ARIADNE
> + =C2=A0 =C2=A0 =C2=A0 tristate "Ariadne support"
> + =C2=A0 =C2=A0 =C2=A0 depends on ZORRO
> + =C2=A0 =C2=A0 =C2=A0 ---help---
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 If you have a Village Tronic Ariadne Et=
hernet adapter, say Y.
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 Otherwise, say N.
> +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 To compile this driver as a module, cho=
ose M here: the module
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 will be called ariadne.
> +
> =C2=A0source "drivers/net/ethernet/arm/Kconfig"
> =C2=A0source "drivers/net/ethernet/atheros/Kconfig"

What's the rationale behind this "restructuring"?
=46WIW, both the A2065 and Ariadne drivers are for AMD LANCE variants
(that is Am7990 and Am79C960)?

And (in some other patch) 82596.c is an Intel driver, not a Motorola dr=
iver.

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
