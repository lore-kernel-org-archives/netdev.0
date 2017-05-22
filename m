From: Stefan Hajnoczi <stefanha@gmail.com>
Subject: Re: vhost/scsi: Delete error messages for failed memory allocations
 in five functions
Date: Mon, 22 May 2017 15:09:35 +0100
Message-ID: <20170522140935.GB1021@stefanha-x1.localdomain>
References: <bafa65e4-08fe-efdb-d836-7657e8a64749@users.sourceforge.net>
 <babc429d-6440-92aa-e1d0-eee2636a8d0f@users.sourceforge.net>
 <20170522094320.GE12205@stefanha-x1.localdomain>
 <557bdff4-6dc2-756d-0d59-9f688ef11f0a@users.sourceforge.net>
 <20170522112320.GA22806@stefanha-x1.localdomain>
 <e6658e56-a2b0-4ecc-0a95-0ba193ff2c97@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="PmA2V3Z32TCmWXqI"
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org,
        virtualization@lists.linux-foundation.org,
        kernel-janitors@vger.kernel.org, Jason Wang <jasowang@redhat.com>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        LKML <linux-kernel@vger.kernel.org>,
        Wolfram Sang <wsa@the-dreams.de>
To: SF Markus Elfring <elfring@users.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:35857 "EHLO
        mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933798AbdEVOJj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 10:09:39 -0400
Content-Disposition: inline
In-Reply-To: <e6658e56-a2b0-4ecc-0a95-0ba193ff2c97@users.sourceforge.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--PmA2V3Z32TCmWXqI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, May 22, 2017 at 01:34:34PM +0200, SF Markus Elfring wrote:
> >> Do you find information from a Linux allocation failure report suffici=
ent
> >> for any function implementations here?
> >=20
> > If kmalloc() and friends guarantee to print a warning and backtrace on
> > every allocation failure, then there's no need for error messages in
> > callers.
> >=20
> > That seems like good justification that can go in the commit
> > description, but I'm not sure if kmalloc() and friends guarantee to show
> > a message (not just the first time, but for every failed allocation)?
>=20
> I am also looking for a more complete and easier accessible documentation
> for this aspect of the desired exception handling.
> How would we like to resolve any remaining open issues there?

No objection from me but please make sure to keep vq_err().

Stefan

--PmA2V3Z32TCmWXqI
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJZIvEfAAoJEJykq7OBq3PIzOgIALqim5eeCJkJKaLpJ9iEuHqN
3fjuMvsMf+ruIhoeHt1hOBIzpCsGF4M89L7suvthrL1uP/6kl3U+jnPwZ/KH/iCT
eDgWZEpGsjPXhu3XAiPHDYp2YL4UwI4rGHyXw4tmozG//Sdqf9RspWpshElHsaAw
FzQezmszkluXZ2EXmgXm1MsAVDKBR7Tcqtqp1Ep6pnKWv5ySmudvu6drUbUsYb1b
tSxM786Gc2epTnIFUsNnyDI0WdZ0RG6XExd77bjojVoXUz5/Cqo9MqkAAIh2lriW
OPvC1bWn45gKKN89n2MTrGdgrylZGUi00RSyVPaYmpeTKGP5uLFxi2+DLz6rLS8=
=DO67
-----END PGP SIGNATURE-----

--PmA2V3Z32TCmWXqI--
