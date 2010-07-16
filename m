From: Helmut Schaa <helmut.schaa@googlemail.com>
Subject: Re: [PATCH 01/11] Removing dead RT2800PCI_SOC
Date: Fri, 16 Jul 2010 12:08:23 +0200
Message-ID: <AANLkTik8M0gNipi_rwVJYbmo_3FfdHs-H4H_XDgTcbhI@mail.gmail.com>
References: <cover.1279110894.git.siccegge@cs.fau.de>
	<20100714131527.GB2352@tuxdriver.com>
	<4C3DCD5C.1080705@openwrt.org>
	<201007151041.55112.bzolnier@gmail.com>
	<AANLkTilqoYMMKYJT-YYbEzdnytUSYa0EylEiJ4x5xXXH@mail.gmail.com>
	<4C4007CD.2070504@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>,
	Felix Fietkau <nbd@openwrt.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	Ivo Van Doorn <ivdoorn@gmail.com>,
	Christoph Egger <siccegge@cs.fau.de>,
	linux-wireless@vger.kernel.org, users@rt2x00.serialmonkey.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	vamos-dev@i4.informatik.uni-erlangen.de,
	Luis Correia <luis.f.correia@gmail.com>
To: Gertjan van Wingerde <gwingerde@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:61893 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964898Ab0GPKI0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jul 2010 06:08:26 -0400
In-Reply-To: <4C4007CD.2070504@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 16, 2010 at 9:18 AM, Gertjan van Wingerde
<gwingerde@gmail.com> wrote:
>
> On 07/16/10 08:57, Helmut Schaa wrote:
> > On Thu, Jul 15, 2010 at 10:41 AM, Bartlomiej Zolnierkiewicz <bzolni=
er@gmail.com <mailto:bzolnier@gmail.com>> wrote:
> >
> > =A0 =A0 On Wednesday 14 July 2010 04:44:44 pm Felix Fietkau wrote:
> > =A0 =A0 > On 2010-07-14 3:15 PM, John W. Linville wrote:
> > =A0 =A0 > > On Wed, Jul 14, 2010 at 02:52:14PM +0200, Ivo Van Doorn=
 wrote:
> > =A0 =A0 > >> On Wed, Jul 14, 2010 at 2:46 PM, Luis Correia <luis.f.=
correia@gmail.com <mailto:luis.f.correia@gmail.com>> wrote:
> > =A0 =A0 > >> > On Wed, Jul 14, 2010 at 13:39, Christoph Egger <sicc=
egge@cs.fau.de <mailto:siccegge@cs.fau.de>> wrote:
> > =A0 =A0 > >> >> While RT2800PCI_SOC exists in Kconfig, it depends o=
n either
> > =A0 =A0 > >> >> RALINK_RT288X or RALINK_RT305X which are both not a=
vailable in Kconfig
> > =A0 =A0 > >> >> so all Code depending on that can't ever be selecte=
d and, if there's
> > =A0 =A0 > >> >> no plan to add these options, should be cleaned up
> > =A0 =A0 > >> >>
> > =A0 =A0 > >> >> Signed-off-by: Christoph Egger <siccegge@cs.fau.de =
<mailto:siccegge@cs.fau.de>>
> > =A0 =A0 > >> >
> > =A0 =A0 > >> > NAK,
> > =A0 =A0 > >> >
> > =A0 =A0 > >> > this is not dead code, it is needed for the Ralink S=
ystem-on-Chip
> > =A0 =A0 > >> > Platform devices.
> > =A0 =A0 > >> >
> > =A0 =A0 > >> > While I can't fix Kconfig errors and the current KCo=
nfig file may be
> > =A0 =A0 > >> > wrong, this code cannot and will not be deleted.
> > =A0 =A0 > >>
> > =A0 =A0 > >> When the config option was introduced, the config opti=
ons RALINK_RT288X and
> > =A0 =A0 > >> RALINK_RT305X were supposed to be merged as well soon =
after by somebody (Felix?)
> > =A0 =A0 > >>
> > =A0 =A0 > >> But since testing is done on SoC boards by Helmut and =
=46elix, I assume the code
> > =A0 =A0 > >> isn't dead but actually in use.
> > =A0 =A0 > >
> > =A0 =A0 > > Perhaps Helmut and Felix can send us the missing code?
> > =A0 =A0 > The missing code is a MIPS platform port, which is curren=
tly being
> > =A0 =A0 > maintained in OpenWrt, but is not ready for upstream subm=
ission yet.
> > =A0 =A0 > I'm not working on this code at the moment, but I think i=
t will be
> > =A0 =A0 > submitted once it's ready.
> >
> > =A0 =A0 People are using automatic scripts to catch unused config o=
ptions nowadays
> > =A0 =A0 so the issue is quite likely to come back again sooner or l=
ater..
> >
> > =A0 =A0 Would it be possible to improve situation somehow till the =
missing parts
> > =A0 =A0 get merged? =A0Maybe by adding a tiny comment documenting R=
T2800PCI_SOC
> > =A0 =A0 situation to Kconfig (if the config option itself really ca=
nnot be removed)
> > =A0 =A0 until all code is ready etc.?
> >
> >
> > Or we could just remove RT2800PCI_SOC completely and build the soc =
specific
> > parts always as part of rt2800pci. I mean it's not much code, just =
the platform
> > driver stuff and the eeprom access.
> >
>
> I'm not sure if that is feasible. Sure, we can reduce the usage of th=
e variable by
> unconditionally compiling in the generic SOC code, but we should not =
unconditionally
> register the SOC platform device, which is currently also under the s=
cope of this
> Kconfig variable.

Ehm, no, the platform device is not registered in rt2800pci at all,
it's just the platform
driver that gets registered there. The platform device will be
registered in the according
board init code (that only resides in openwrt at the moment).

Helmut
