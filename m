From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH 0/4] wimax: Kbuild / rfkill-build / PM fixes (v3)
Date: Wed, 07 Jan 2009 16:10:53 -0800
Message-ID: <4965448D.7000607@oracle.com>
References: <cover.1231355768.git.inaky@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, wimax@linuxwimax.org, greg@kroah.com,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	linux-wimax@intel.com
To: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <cover.1231355768.git.inaky@linux.intel.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Inaky Perez-Gonzalez wrote:
> These four patches fix build issues reported by Randy Dunlap on the
> linux-next tree for Jan 6 and Jan 7:
>=20
> http://lkml.org/lkml/2009/1/6/340
> http://lkml.org/lkml/2009/1/7/360
>=20
> The issue fixed by patch #3 wasn't reported on the emails but was
> uncovered while discussing the fixes.
>=20
> This applies to the wimax tree kept in gregkh's repository:
>=20
> http://kernel.org/pub/linux/kernel/people/gregkh/gregkh-2.6/gregkh-04=
-usb/

Ack.  They all work for me.  Thanks.


> Changes in v3
>=20
> - Add patch #4, wrapping access to power-saving members of the struct
>   usb_device in #ifdef CONFIG_PM.=20
>=20
> Changes in v2
>=20
> - fixed silly one-char typo #ifndef CONFIG_BUG vs #ifdef CONFIG_BUG
>   reported by Ilpo J=C3=A4rvinen=20
>=20
> Inaky Perez-Gonzalez (4):
>   wimax: fix '#ifndef CONFIG_BUG' layout to avoid warning
>   wimax: fix kconfig interactions with rfkill and input layers
>   wimax: testing for rfkill support should also test for
>     CONFIG_RFKILL_MODULE
>   i2400m/usb: wrap USB power saving in #ifdef CONFIG_PM
>=20
>  drivers/net/wimax/i2400m/usb.c |    6 ++++++
>  net/wimax/Kconfig              |   14 ++++++++++++++
>  net/wimax/id-table.c           |    8 +++++---
>  net/wimax/op-rfkill.c          |    2 +-
>  4 files changed, 26 insertions(+), 4 deletions(-)
>=20


--=20
~Randy
