From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next V3 0/2] igb: ptp hardware clock
Date: Thu, 19 Jan 2012 01:56:45 -0800
Message-ID: <1326967005.2707.0.camel@jtkirshe-mobl>
References: <cover.1325964581.git.richardcochran@gmail.com>
	 <1325984559.2641.0.camel@jtkirshe-mobl>
	 <20120119093906.GC4420@cherladcori01>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-+aWa8XMfbojVJt/4n1bM"
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	Jacob Keller <jacob.e.keller@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Thomas Gleixner <tglx@linutronix.de>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:40201 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752267Ab2ASJ46 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jan 2012 04:56:58 -0500
In-Reply-To: <20120119093906.GC4420@cherladcori01>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-+aWa8XMfbojVJt/4n1bM
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2012-01-19 at 10:39 +0100, Richard Cochran wrote:
> On Sat, Jan 07, 2012 at 05:02:39PM -0800, Jeff Kirsher wrote:
> > On Sat, 2012-01-07 at 20:38 +0100, Richard Cochran wrote:
> > > * ChangeLog
> > > ** V3
> > >    - Driver compiles even without CONFIG_PTP_1588_CLOCK.
> > >    - Timestamping always works, even when PTP code missing or fails.
> > > ** V2
> > >    - Fixed wrong bit shifting in the 82576 code.
> > >    - Explained the timestamp locking with a comment in the code.
> > >    - Preserved the comments from the original timecompare
> > > implementation.
> > >    - Added an additional test within the overflow counter code to fix
> > >      a race condition. Details of the problem are given in the commit
> > >      message.
> ...
> > Thanks Richard, I will add this series to my queue.
>=20
> Jeff,
>=20
> Please hold off with these. I adapted the driver to use
> timecounter/cyclecounter as Jacob suggested, and the result is surely
> nicer. I will post a V4 after I finish testing it.
>=20
> Thanks,
> Richard
>=20

Ok, I will await v4 of the patches.  Thanks Richard!

--=-+aWa8XMfbojVJt/4n1bM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABCgAGBQJPF+jdAAoJEOVv75VaS+3ODZ8P/0m4bc8x4RiW9iJiltHTWr1v
RE0mu7eZBsK91BoXcNDNylD4Y2maooyAEpLImAWM0CmG8p8QMGW4It+ySNhJtXSX
edMxDxq4Pv+nVc0HsZk7rL5U2SI+Iqdj/cnKklBe3WHkkw4vQyRpzxF0nQPybv5+
TuEiBLbEjMibKwr01QngWSOE/f2aK8iAKjnkJvRmUT6x2b/n8gePP/k6/wVtpFjn
vEgHW+20bFS1v7izqt0C/8WEo9Z67QzxLPiss0KSwB3dw4OPKwkqzpjWhn3YO6MF
n8rq8LjZUBkYIx5nyOF+3M2+Tr9CUa99gJ6pcZkSLZz/4XgkTxNXOEtDF6BIQFfe
2dBDeWlVZiKA1HLtOH9tpgZNCQRPqN6lISrPC5BWsZlz+JFNNNDRnHS1lk+bVSR2
GVuKSdfeUZTaN03EQlQ3CEdlb5E4xSdFDdgYwkxINHRWDsWYM5UlES6rccwtFkEC
5upYx1Mn9YHTiWt3fRIqAS8zCU6ZyXbnwYh8/hK4NuxMpvMdJJTyj+26yvKC4NDz
8V92oW29s0KqLF0eZU9xMKmeUZJgjcDx4y6oV8OpeSKotpMi3QamE4QcAJmE19pu
iATkXx6IfFG1KBiAYRUSRnGWMc6brHnCl3ioNfFp9p1aed/zAiHghQP8ZByD15Aw
hlClKni9VlvxwZgYbNts
=na50
-----END PGP SIGNATURE-----

--=-+aWa8XMfbojVJt/4n1bM--
