From: Gregory Haskins <gregory.haskins@gmail.com>
Subject: Re: [PATCH v3 3/6] vbus: add a "vbus-proxy" bus model for vbus_driver
 objects
Date: Mon, 17 Aug 2009 09:02:40 -0400
Message-ID: <4A8954F0.3040402@gmail.com>
References: <20090814154125.26116.70709.stgit@dev.haskins.net> <20090814154308.26116.46980.stgit@dev.haskins.net> <20090815103243.GA26749@elte.hu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig51FCF08CCE8E65DE010D1EC3"
Cc: Gregory Haskins <ghaskins@novell.com>, kvm@vger.kernel.org,
	Avi Kivity <avi@redhat.com>,
	alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20090815103243.GA26749@elte.hu>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig51FCF08CCE8E65DE010D1EC3
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Ingo Molnar wrote:
> * Gregory Haskins <ghaskins@novell.com> wrote:
>=20
>> This will generally be used for hypervisors to publish any host-side
>> virtual devices up to a guest.  The guest will have the opportunity
>> to consume any devices present on the vbus-proxy as if they were
>> platform devices, similar to existing buses like PCI.
>>
>> Signed-off-by: Gregory Haskins <ghaskins@novell.com>
>> ---
>>
>>  MAINTAINERS                 |    6 ++
>>  arch/x86/Kconfig            |    2 +
>>  drivers/Makefile            |    1=20
>>  drivers/vbus/Kconfig        |   14 ++++
>>  drivers/vbus/Makefile       |    3 +
>>  drivers/vbus/bus-proxy.c    |  152 ++++++++++++++++++++++++++++++++++=
+++++++++
>>  include/linux/vbus_driver.h |   73 +++++++++++++++++++++
>>  7 files changed, 251 insertions(+), 0 deletions(-)
>>  create mode 100644 drivers/vbus/Kconfig
>>  create mode 100644 drivers/vbus/Makefile
>>  create mode 100644 drivers/vbus/bus-proxy.c
>>  create mode 100644 include/linux/vbus_driver.h
>=20
> Is there a consensus on this with the KVM folks? (i've added the KVM=20
> list to the Cc:)
>=20
>=20

Hi Ingo,

Avi can correct me if I am wrong, but the agreement that he and I came
to a few months ago was something to the effect of:

kvm will be neutral towards various external IO subsystems, and instead
provide various hooks (see irqfd, ioeventfd) to permit these IO
subsystems to interface with kvm.

AlacrityVM is one of the first projects to take advantage of that
interface.  AlacrityVM is kvm-core + vbus-core + vbus-kvm-connector +
vbus-enhanced qemu + guest drivers.  This thread is part of the
guest-drivers portion.  Note that it is specific to alacrityvm, not kvm,
which is why the kvm list was not included in the conversation (also an
agreement with Avi: http://lkml.org/lkml/2009/8/6/231).

Kind Regards,
-Greg


--------------enig51FCF08CCE8E65DE010D1EC3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkqJVPEACgkQP5K2CMvXmqHhIACePG05qVQu/pdlu1Gh0/YSgvgb
4ZsAn3tT2aw3ki6Uq90+Y/ZHjd/4lQEZ
=7cSS
-----END PGP SIGNATURE-----

--------------enig51FCF08CCE8E65DE010D1EC3--
