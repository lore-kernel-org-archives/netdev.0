From: Stefan Hajnoczi <stefanha@gmail.com>
Subject: Re: [PATCH 2/2] vhost/scsi: Delete error messages for failed memory
	allocations in five functions
Date: Mon, 22 May 2017 15:08:43 +0100
Message-ID: <20170522140843.GA1021@stefanha-x1.localdomain>
References: <bafa65e4-08fe-efdb-d836-7657e8a64749@users.sourceforge.net>
	<babc429d-6440-92aa-e1d0-eee2636a8d0f@users.sourceforge.net>
	<20170522094320.GE12205@stefanha-x1.localdomain>
	<557bdff4-6dc2-756d-0d59-9f688ef11f0a@users.sourceforge.net>
	<20170522112320.GA22806@stefanha-x1.localdomain>
	<20170522123833.asx2biaw4xaz4qpv@mwanda>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2231780079600603354=="
Cc: kvm@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>,
	netdev@vger.kernel.org, Wolfram Sang <wsa@the-dreams.de>,
	kernel-janitors@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	virtualization@lists.linux-foundation.org,
	SF Markus Elfring <elfring@users.sourceforge.net>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20170522123833.asx2biaw4xaz4qpv@mwanda>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org


--===============2231780079600603354==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ZGiS0Q5IWpPtfppv"
Content-Disposition: inline


--ZGiS0Q5IWpPtfppv
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, May 22, 2017 at 03:38:33PM +0300, Dan Carpenter wrote:
> On Mon, May 22, 2017 at 12:23:20PM +0100, Stefan Hajnoczi wrote:
> > I'm not sure if kmalloc() and friends guarantee to show
> > a message (not just the first time, but for every failed allocation)?
> >
>=20
> It prints multiple times, but it's ratelimited.  It can also be disabled
> using a config option.
>=20
> See slab_out_of_memory().

Thanks!

Stefan

--ZGiS0Q5IWpPtfppv
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJZIvDrAAoJEJykq7OBq3PIUH4H/3L9zlXLIFIjeO3N1Yqz8X83
ZJlhtzC5NFsR/Aj1bu+OQ6Z2tQzlPSx03VKQEd9A9FXLOSQY2gWhrqwj6ZGPfoTf
YqiS0O0Xu7J/AODkWPS/FJ9Z6KRihD5Qi/EjczFlDVrcGDq60f4n9w63FI2U49sy
cqLyHzmiZjISDMXzF4LfizhWU4skPVF+6DhQeUyizDgwrn1xHP5xFP+La+U9DX/8
Gbdn4zzQKmtSqRPtsbpFsze3OXNnXGIcsIYLvqH4N2Q+lM0VTDKbkF0Y2P4Ud8m8
okdgoTzvKIHMzq/jMlxJCnIegkO53gWdALQaVDur5tPkiOVzucGZuQpmTdofZbI=
=EgHR
-----END PGP SIGNATURE-----

--ZGiS0Q5IWpPtfppv--

--===============2231780079600603354==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Virtualization mailing list
Virtualization@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/virtualization
--===============2231780079600603354==--
