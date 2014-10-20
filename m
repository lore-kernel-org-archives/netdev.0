From: Kevin Fenzi <kevin@scrye.com>
Subject: Re: localed stuck in recent 3.18 git in copy_net_ns?
Date: Mon, 20 Oct 2014 14:53:59 -0600
Message-ID: <20141020145359.565fe5e6@voldemort.scrye.com>
References: <20141020141515.0688bf33@voldemort.scrye.com>
	<20141020204326.GA25668@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 boundary="Sig_/CWmk_C.B8yfFdG+vV4mMMgc"; protocol="application/pgp-signature"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 75-148-32-185-Colorado.hfc.comcastbusiness.net ([75.148.32.185]:44517
	"EHLO mail.scrye.com" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1752835AbaJTUyB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Oct 2014 16:54:01 -0400
In-Reply-To: <20141020204326.GA25668@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/CWmk_C.B8yfFdG+vV4mMMgc
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 20 Oct 2014 16:43:26 -0400
Dave Jones <davej@redhat.com> wrote:

> I've seen similar soft lockup traces from the sys_unshare path when
> running my fuzz tester.  It seems that if you create enough network
> namespaces, it can take a huge amount of time for them to be iterated.
> (Running trinity with '-c unshare' you can see the slow down happen.
> In some cases, it takes so long that the watchdog process kills it --
>  though the SIGKILL won't get delivered until the unshare() completes)
>=20
> Any idea what this machine had been doing prior to this that may have
> involved creating lots of namespaces ?

That was right after boot. ;)=20

This is my main rawhide running laptop.

A 'ip netns list' shows nothing.

kevin

--Sig_/CWmk_C.B8yfFdG+vV4mMMgc
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCgAGBQJURXZnAAoJEEs3sNgP+7teqmMQAL3/ZMJpSBj0A7EhePGt5t/J
4TQhLmj4I4k2bT/HGBbFaWAM/n/6S8CRF5yIBMwlb2XsiBYBOtZDpinmjK6/Scub
hSNC08tWT7ZbdJFVAaqW1y9mKEHq+GAg1vhYjqTnncU7EO/y/MD9SrGUfFm9zfDH
hJ8M6EtqHfGprj48wom2l0Ec5T12L2qioNqW5UyFC3ygpsawmeaok6zoOAZCJAb4
M3Jsty8L8U+NLcMYaTe3su/ax45zY60Kk1b8yu+K4qI9hEeGlrVFpFdZO+5D77Me
N1V8KR1OKtxH+fomwdi8Vegt9b9JPR69j7YnuMxVG9CZMGUGvX/xdFcmBm/ij0ea
9kYE0doteCTjGhCptYEF4d6zqLip1SuvDVNNs2P+DBIf907PXZr+3aPz3H08BASY
ydu1tsz8m+eoivZoLHq7Knw4iog/4AyQOKfoCwN/PU7eBNWCY56Vxm7u4d9CSEtJ
VAVV60+29bBGjlgTeZbOlwxvUitq/4667vMJ9j8mNBmd0/UHnFPXgNxJDvqAI+JN
AAC86tDscMdoEu4lhIFkgfma6jAmrZmUlTQTPcYNcROjSSFj/BSeejC/GpqUr71Y
bwC3TFxLA9Ltn62dExDDhgGnNm/4xrKH7SGyObegdyvwWBMc3Nvko0XAr4BXxSnl
cON3fSGC2+/Fv8MFIROJ
=sHf9
-----END PGP SIGNATURE-----

--Sig_/CWmk_C.B8yfFdG+vV4mMMgc--
