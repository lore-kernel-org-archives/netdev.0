From: Henrik Austad <henrik@austad.us>
Subject: Re: [next-queue PATCH v6 4/5] net/sched: Add support for HW
 offloading for CBS
Date: Thu, 12 Oct 2017 10:04:12 +0200
Message-ID: <20171012080412.GB29396@sisyphus.home.austad.us>
References: <20171012005449.26533-1-vinicius.gomes@intel.com>
 <20171012005449.26533-5-vinicius.gomes@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="6sX45UoQRIJXqkqR"
Cc: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
        jhs@mojatatu.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        andre.guedes@intel.com, ivan.briano@intel.com,
        jesus.sanchez-palencia@intel.com, boon.leong.ong@intel.com,
        richardcochran@gmail.com, levipearson@gmail.com,
        rodney.cummings@ni.com
To: Vinicius Costa Gomes <vinicius.gomes@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f44.google.com ([209.85.215.44]:56137 "EHLO
        mail-lf0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753217AbdJLIEK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 04:04:10 -0400
Received: by mail-lf0-f44.google.com with SMTP id p184so4993910lfe.12
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2017 01:04:09 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20171012005449.26533-5-vinicius.gomes@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--6sX45UoQRIJXqkqR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Oct 11, 2017 at 05:54:48PM -0700, Vinicius Costa Gomes wrote:
> This adds support for offloading the CBS algorithm to the controller,
> if supported. Drivers wanting to support CBS offload must implement
> the .ndo_setup_tc callback and handle the TC_SETUP_CBS (introduced
> here) type.

This also answered my question in the previous patch (as to how hw=20
offloading can be enabled).

/me goes off to test the series
Looking good so far!

-Henrik

--6sX45UoQRIJXqkqR
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlnfIfwACgkQ6k5VT6v45lmumQCgxLRfnF+ZT/bikdbzHaheG3Vn
QAMAnRiuwj5+3Mi5cIlWFjAS1LAvjH64
=OVi3
-----END PGP SIGNATURE-----

--6sX45UoQRIJXqkqR--
