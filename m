From: Pawel Sokolowski <falcon@muflon.linux.pl>
Subject: Re: 2.6.4-rc1 + hp100 EISA, not working
Date: Tue, 2 Mar 2004 00:04:11 +0100 (CET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0403012353560.25624@don.falconne.eu.org>
References: <Pine.LNX.4.58.0402292149230.25624@don.falconne.eu.org>
 <wrpptbwyiyx.fsf@hina.wild-wind.fr.eu.org>
Reply-To: pawel.sokolowski@muflon.linux.pl
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=iso-8859-2
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Marc Zyngier <mzyngier@freesurf.fr>
In-Reply-To: <wrpptbwyiyx.fsf@hina.wild-wind.fr.eu.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I've seen things you people wouldn't believe. You writing:

>Pawel> I don't know if it's related to this problem but at earlier stage=
 of
>Pawel> booting I'm getting following messages:
>Pawel> EISA: Probing bus 0 at eisa0
>Pawel> EISA: Mainboard HWPC061 detected.
>Pawel> EISA: slot 2 : HWP1940 detected (disabled).
>Pawel> EISA: Detected 1 card.
>Try passing 'eisa_bus.enable_dev=3D2' to your kernel parameters. Your
>card is tagged as unconfigured by BIOS, and thus is skipped by the
>probing logic. See Documentation/eisa.txt for details.

This machine has RAM BIOS booted from floppy. I ran it and EISA
configure utility to check this once more. Card is enabled and not
locked. I added eisa_bus.enable_dev=3D2 parameter but it didn't help much.
I'm getting:

EISA: Probing bus 0 at eisa0
EISA: Mainboard HWPC061 detected.
EISA: slot 2 : HWP1940 detected (forced enabled).
EISA: Detected 1 card.

I added this final entry you mailed but nothing changed. Still - module
loads and unloads cleanly and without any warnings on 2.6.4-rc1. But
does nothing - not a single line in logs/dmesg after it's loaded. Card
does not work after modprobe, I can't get interface up.


If you need more details or some config files, please, let me know.

--=20
  ,d$$$$$P.d$$b     d$P  ,gd$$$$$,gd$$$$g. ,$$$b._$$P               RLU #=
172534
  ggggggggggggg.   ggs  ,gg     ,gg    ,gg ggp,ggggg           Pawe=B3 So=
ko=B3owski
 d$P""""'""""Y$$. d$P   d$P     d$P   ,d$Pd$P `Y$$P      falcon@muflon.li=
nux.pl
d$P           Y$$d$$$$$P`Y$$$$$'`Y$$$$$P'd$P   d$P    Replicant (M) Des: =
Falcon
