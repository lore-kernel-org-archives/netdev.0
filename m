From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: Re:Re: [linux-nics] [PATCH] e1000 in linux-3.18.0: a potential
 bug
Date: Sat, 20 Dec 2014 04:49:31 -0800
Message-ID: <1419079771.2461.94.camel@jtkirshe-mobl.home>
References: <000d01d01c29$a9edb870$fdc92950$@163.com>
	 <1419071660.2461.85.camel@jtkirshe-mobl.home>
	 <79ea17da.119c.14a67bcadd1.Coremail.baijiaju1990@163.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-ifvNCdSrqYgpL0nzLfhx"
Cc: netdev <netdev@vger.kernel.org>,
	e1000-devel <e1000-devel@lists.sourceforge.net>
To: =?UTF-8?Q?=E7=99=BD=E5=AE=B6=E9=A9=B9?= <baijiaju1990@163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:63800 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752812AbaLTMtb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Dec 2014 07:49:31 -0500
In-Reply-To: <79ea17da.119c.14a67bcadd1.Coremail.baijiaju1990@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-ifvNCdSrqYgpL0nzLfhx
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2014-12-20 at 20:47 +0800, =E7=99=BD=E5=AE=B6=E9=A9=B9 wrote:
> Thanks for the reply!
> I run the driver normally, and monitor all function calls in runtime,
> and then find this violation.=20

Adding netdev and e1000-devel back onto the CC since Jia-Ju Bai removed
them in his reply...

>=20
> At 2014-12-20 18:34:20,"Jeff Kirsher" <jeffrey.t.kirsher@intel.com> wrote=
:
> >On Sat, 2014-12-20 at 15:50 +0800, Jia-Ju Bai wrote:
> >> I have actually tested e1000 driver on the real hardware(Intel 82540EM
> >> PCI
> >> Gigabit Ethernet Controller), and find a potential bug:
> >> The target file is drivers/net/ethernet/intel/e1000/e1000_main.c,
> >> which is
> >> used to build e1000.ko.
> >>=20
> >> (1) In the normal process, netif_napi_add is called in e1000_probe,
> >> but
> >> netif_napi_del is not called in e1000_remove. However, many other
> >> ethernet
> >> card drivers call them in pairs, even in the error handling paths,
> >> such as
> >> r8169 and igb.
> >>=20
> >> Meanwhile, I also write the patch to fix the bug. I have run the patch
> >> on
> >> the hardware, it can work normally and fix the above bug.
> >
> >Was this a bug you actually saw?  Or a theoretical bug based on code
> >review?
> >
> >I do not mind adding this to my queue so that we can review and test the
> >patch, although this will cause a fair amount of regression testing.
>=20
>=20



--=-ifvNCdSrqYgpL0nzLfhx
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUlXBbAAoJEOVv75VaS+3O93AP/RWgNuM1ENoVciAjZ3IjsExd
fkZ1Z1ZQq4vdKDp96Q7YuF1TuOQj0ieXZ9QkLyZktN5ixFK4J7/Z3T8OHvdcj8xE
F+Gr45Yrk/Tuq1bhRp4s4484NqtAK022/IxQedK5qcnj7JUt22ZPYdntvs/66/VM
+4DiGyjdXFitra9ZxQHdHVlwOlvnKBWzFYnlu9iH1qFVxWKIxVHllbAKh0EHG67S
cISszxylSotnUGGt+JPOoJ4YRIi9LUCjNRWR2qtkn7dtEKBJ3eziQZRInDFw9rRx
h5zeJzR4eyVbQiAyd+SWY7dEcmESUMBO7DkVCxwqul9WJ6rkriVWxIGLyjgtYCGD
KFSs0nzdavqeHAKphNO6cxv4iMySXWYOlbOn60QkvAsxqGlhYOiSg8ZawW1S7RVJ
tq/+EfKq6AnOiUHQBqKdoPY2hAGJedoV6NZF9juEUqoBUKPKj96lc4ORk7nkbCIN
qpkE45litDFmeJXHgcDxTrUHnXqS7LlXtGer+QEdQ0Wpisw2h7jBPnPbYUeqTzvv
bPAqtw2sh0jqPlqk4ndFTrCK0bf7qArlwlP0yhboOgY+t1FiWaZenpawlyfhOZm/
39ZIdt9R6e7HpMqVoqzczddxutDcsyea3tBaKKhi2uAlKhV4RlS4Hzd9FblkqE7q
TeON9AeHCmEJg1UAP9On
=TmN6
-----END PGP SIGNATURE-----

--=-ifvNCdSrqYgpL0nzLfhx--
