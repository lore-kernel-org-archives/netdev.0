From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH for bnxt_re V3 03/21] bnxt_re: register with the NIC
 driver
Date: Mon, 16 Jan 2017 10:33:20 +0200
Message-ID: <20170116083320.GB32481@mtr-leonro.local>
References: <1482225211-22423-1-git-send-email-selvin.xavier@broadcom.com>
 <1482225211-22423-4-git-send-email-selvin.xavier@broadcom.com>
 <20170115194143.GE20392@mtr-leonro.local>
 <CA+sbYW2SMbExwyw20TZtn3U13fkJvKCs5P8w5LdovN4Q3u0sjg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="tjCHc7DPkfUGtrlw"
Cc: Doug Ledford <dledford@redhat.com>, linux-rdma@vger.kernel.org,
        Linux Netdev List <netdev@vger.kernel.org>,
        Michael Chan <michael.chan@broadcom.com>,
        Eddie Wai <eddie.wai@broadcom.com>,
        Devesh Sharma <devesh.sharma@broadcom.com>,
        Somnath Kotur <somnath.kotur@broadcom.com>,
        Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
To: Selvin Xavier <selvin.xavier@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:48138 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750817AbdAPIdU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 16 Jan 2017 03:33:20 -0500
Content-Disposition: inline
In-Reply-To: <CA+sbYW2SMbExwyw20TZtn3U13fkJvKCs5P8w5LdovN4Q3u0sjg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--tjCHc7DPkfUGtrlw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Jan 16, 2017 at 01:38:40PM +0530, Selvin Xavier wrote:
> On Mon, Jan 16, 2017 at 1:11 AM, Leon Romanovsky <leon@kernel.org> wrote:
> > Recently, in one of our submission to netdev and rdma, we got
> > a reminder that inline functions shouldn't be in *.c. Let for
> > the compiler to decide.
> >
> > IMHO, it should be open-coded without wrappers and honestly I failed to
> > understand why do you need so many wrappers for one line standard kernel
> > functions.
>
> Agreed. During the initial days of development, we had some debug code also
> inside these wrapper functions. Since the debug code was removed before upstream
> submission, this function ended up as a wrapper for standard kernel function.
> It makes perfect sense to knock off these wrapper functions. I will
> queue it for next
> clean-up/bug fix patch series.

I'm fine with it as long as it's done.

>
> Thanks

--tjCHc7DPkfUGtrlw
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlh8hVAACgkQ5GN7iDZy
WKey1w/+M5SwWmXdmG12wS4gef3Ru0t9diKnIFym3XF9KlmUxV3oo+35M/BInw2e
ZQ0c+2Uk35XwzEToVeN8qLCxaHSGAZK3dLB/KfbsaKum1yEMWnpybGB784Z1KkL5
NXIBF8Vojc0T1obUT8iWf40cKk8dml86cbo4RxBHdVhiymS0TaaUkxJo5VXmhV9k
1HAgZRdWp4LpEEuIpsH/GAaqn7RlKjRuAV5sX0ZD3EovaGjTYSiSjQT5tqU7sV7Z
Q1SVJ9OWCJpHtB6OCRI3PPHti0zahtcAAgOumyKcd3Lom3b6rtgaYc+SbajSPn1J
ltbH7Oneq1zspBVDm7dDrYefoHdmaFYHPdcCj4aMqrwtJT2s10lryLgAYXhjlPZN
OWIzaD5E2bWLAk4YNvkctwUmRLabZvmQQd2BR6acXbCAyLvPefDCbILJZvf+50/w
KGdnQlaXT2D+7ChJoeXkfKMKT2VrCx/Ribir45V9B05Fc7fQldBFMw3eIJJPBRfo
PzolXbWGWyVPAiX2+2ckth/u+WwxNEpaQRLuE8U3doLNbibTmAF1V7+ZEf2i0Giu
SxbIEspZyp+8RTS+k3m0IVKcGrHTXvAJ75Vmu8BcozWhtLNmAhgrpWSwoQP4pot2
T6K/cZ6c/AtoopQbMSdGsRaUJg9LoztbGiz9C0jdLDLe9CiqcEk=
=vSj2
-----END PGP SIGNATURE-----

--tjCHc7DPkfUGtrlw--
