From: Jan Kasprzak <kas@fi.muni.cz>
Subject: Re: skge: PCI error cmd=0x117 status=0x22b0
Date: Fri, 14 Nov 2008 18:55:07 +0100
Message-ID: <20081114175507.GC7172@fi.muni.cz>
References: <20081114153646.GB7172@fi.muni.cz> <20081114084209.0ee411fd@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from minas.ics.muni.cz ([147.251.4.40]:48932 "EHLO minas.ics.muni.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751674AbYKNRzK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Nov 2008 12:55:10 -0500
Content-Disposition: inline
In-Reply-To: <20081114084209.0ee411fd@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
: On Fri, 14 Nov 2008 16:36:46 +0100
: Jan Kasprzak <kas@fi.muni.cz> wrote:
:=20
: > 	Hello,
: >=20
: > I have an ASUS M2R32-MVP board with the skge network card. From tim=
e to time
: > the network freezes with the following message (this one taken from
: > 2.6.27-rc7, another one added even with timing information at the e=
nd
: > of this mail):
: >=20
: > skge 0000:03:04.0: PCI error cmd=3D0x117 status=3D0x22b0
: > skge 0000:03:04.0: unable to clear error (so ignoring them)
:=20
: The device is getting a PCI master abort on a DMA.
: Either, you have hardware issues, or there is a driver bug when acces=
sing
: a particular memory address.  Do you have 4G or more of memory?

	Yes (I have written it in my previous mail) - I have 8 GB of RAM.
Can - for example - a non-linear memory (i.e. the memory hole remapping=
)
be a problem? IIRC, I have it set to "on" in my BIOS setup.

: Some motherboards are crap and don't actually allow DMA from high mem=
ory.

	With 8 GB only half of my RAM is below the 32-bit barrier,
so I guess if this was a problem, I would got this error more often
(every second packet on average?).

	OK, I will try to poke my HW vendor. Thanks,

-Yenya

--=20
| Jan "Yenya" Kasprzak  <kas at {fi.muni.cz - work | yenya.net - privat=
e}> |
| GPG: ID 1024/D3498839      Fingerprint 0D99A7FB206605D7 8B35FCDE05B18=
A5E |
| http://www.fi.muni.cz/~kas/    Journal: http://www.fi.muni.cz/~kas/bl=
og/ |
>>  If you find yourself arguing with Alan Cox, you=E2=80=99re _probabl=
y_ wrong.  <<
>>     --James Morris in "How and Why You Should Become a Kernel Hacker=
"  <<
