From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Bug#690845: ethtool: incorrect WoL detection on Broadcom NX II
 rev < 12
Date: Wed, 24 Oct 2012 15:23:02 +0100
Message-ID: <1351088582.5283.83.camel@deadeye.wl.decadent.org.uk>
References: <20121018134717.9579.22997.reportbug@palomino.museglobal.com>
	 <1350570748.26833.102.camel@deadeye.wl.decadent.org.uk>
	 <CAG2Wgfee=qsiUhAk5reYTypcOZL0kM5A58J+LjB1wuQ_k9FrfA@mail.gmail.com>
	 <1350610209.22276.6.camel@deadeye.wl.decadent.org.uk>
	 <1350675530.8764.131.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	 <CAG2Wgfdn52R2FYh77-2ZHCFVwe8d0MOv_4but6aOsU50jF-+Lg@mail.gmail.com>
	 <1350946459.8764.145.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	 <1350956707.5283.48.camel@deadeye.wl.decadent.org.uk>
	 <1350958687.8764.170.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-QHlwnc7b17P64z5W0+0+"
Cc: 690845@bugs.debian.org, Teodor MICU <mteodor@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:56530 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934800Ab2JXOXU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Oct 2012 10:23:20 -0400
In-Reply-To: <1350958687.8764.170.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-QHlwnc7b17P64z5W0+0+
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2012-10-22 at 19:18 -0700, Michael Chan wrote:
> On Tue, 2012-10-23 at 02:45 +0100, Ben Hutchings wrote:=20
> > Well we knew that much!  Is the problem that the system firmware 'owns'
> > the WoL control registers so the host can't safely change them?  Is it
> > possible to *read* the WoL configuration, if not to change it?=20
>=20
> It's a hardware problem and I don't understand all the details.  There
> is an internal PCIX to PCIE bridge on this chip and it gates the NIC's
> PME event.  During S5 reset, the bridge gets reset by the BIOS and the
> WoL setting done by the driver will no longer work.  Newer chip revs
> have fixed the problem in hardware.
>
> The driver reads the pre-boot WoL setting from NVRAM and it becomes the
> ethtool WoL default setting.  Apparently, it is also not working in this
> case.  I know that it doesn't work on some LOM designs as the setting is
> actually in BIOS NVRAM as opposed to NIC NVRAM.

Thanks for the explanation.  This does seem to be unfixable, then,
unfortunately.

Ben.

--=20
Ben Hutchings
Never attribute to conspiracy what can adequately be explained by stupidity=
.

--=-QHlwnc7b17P64z5W0+0+
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUIf5xue/yOyVhhEJAQoSqw/+InuHTQgqWLJfnO2/DZw/bpKMPSUJ+whS
nlJ5b8ovaDnRDrdtpuED3d/+KhE//5qjgLyixeoCB4EL5/zu46c2WVp4FN71PGEP
pAbH/2cmmAI/EcL4CPaWsoVdhMIV+s0KzXncDf3NOgtCHcjQ/jl5hCrfggE0TeXm
miZmGN9uHwmEi8kbZFp4BBfjJMITmrwBYdqOnkcgQAmsZ4tfTDuhXKqYUy+5qU/U
YXXN7/J3G4PdQCpF1R6skQE6j4DgVOVbidaBRE0rqdEpjKFMmDaYCzeMCTiDLmMo
5pxmJFh/rqRPPnKpSORCHGGcDVwCA/DpeHdyVn5t7lJ1IxUqh6nJwzXZA8+r7vyU
g/MKLOSe2ZRemSaRz6pfuQxzwiDqsLeFQjKM+imDxhkyeKWoGaLer6RMnZt8d0pB
ihk1maTvG6IspAMWIWALD0wBH/m4ShamL7P6+SckZfFVRB9zbDhhxlsmnCRq2Ff0
gtXM91zlLm2XIZly8QFvocWl2w2Twl3tjnb362TtvlqUwRficjYX19Hu2b0/bEDX
dD2Etl9qCO2rdSBhAghghg28NUmUhiFqNoGNCpchBpTtzEzLpC/eOPZqXrLa7hC7
sDXkvEObfP4qg7TP/SZQvQ5kXRilNVpfhXOsh+8rE97mXW44HW5bTI++alNYTEnu
onesXVZV4/U=
=93Jq
-----END PGP SIGNATURE-----

--=-QHlwnc7b17P64z5W0+0+--
