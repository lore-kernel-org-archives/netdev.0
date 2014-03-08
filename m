From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] e1000: do not allow watchdog to reenable transmits on
 shutdown (v2)
Date: Fri, 07 Mar 2014 16:47:26 -0800
Message-ID: <1394239646.2582.0.camel@jtkirshe-mobl>
References: <20140307020420.GA10797@amt.cnet>
	 <1394162671.2214.36.camel@jtkirshe-mobl> <20140307205926.GA5041@amt.cnet>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-4ppgMENkhMc1yXNWIrjX"
Cc: Vladimir Davydov <VDavydov@parallels.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Marcelo Tosatti <mtosatti@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:33588 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751590AbaCHArk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Mar 2014 19:47:40 -0500
In-Reply-To: <20140307205926.GA5041@amt.cnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-4ppgMENkhMc1yXNWIrjX
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2014-03-07 at 17:59 -0300, Marcelo Tosatti wrote:
> There is a race on the shutdown path of the e1000 driver
> that allows the card to DMA into free'd memory.
>=20
> The symptoms are similar to those described at
> commit d5bc77a223b0e9b9dfb002048d2b34a79e7d0b48,
> "e1000: don't enable dma receives until after dma address has been
> setup", where memory corruption is visible due to E1000_RXD_STAT_DD
> being written to the DMA transfer descriptor.
>=20
> Fix by not allowing the watchdog and tx fifo stall detector
> to re-enable E1000_TCTL_EN.
>=20
> Signed-off-by: Marcelo Tosatti <mtosatti@redhat.com>

Thanks for the updated patch, I will update my queue.

--=-4ppgMENkhMc1yXNWIrjX
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJTGmieAAoJEOVv75VaS+3OycEP/ipMd+jNa399m6PNS2URtrSr
8BMavhGJMLTtlb3I1JhVCZtrTr8X7tfOwUfic17hGI1sOQtYtJHrXmCeoLKEqmM9
dTAwy0sGaTUGobWTw1/IzMWbK4peo6+4KvNeYa/70NUca9nZTRqUzKa63H/UAJrQ
2ENQgkwD+be6MUSwurMZgAf27vLLgTvOB/enyBzyELMOW+7ouX67Ca0Ud8E/JNMl
VDTrgwqiafE2xuRnpCm9QNXmDRfF4kgvct9OJreziVj1/kB9LN3f28nEbqKnIYmH
lqqXXLBaSZgs5D8/jIYbJlhOsgOMIn06MUWu77o22S52v/DdFnw0u/3J5Su0mNuV
CtS5bQb0yV+iSWQYOgIhVWPnMc1J1a9Qk/+6xCLRDmqnFWvz8ynJn4HChIqSNX6z
p1cxduDa1waZ5Gc/YNXyoOH91k1UHRuk8uHwNrhzqObx4EL/96pkMmDhvZTnm/Rz
6mso2ykF7Daf8jV7oIHMjKu6cI92QyQTtUAEepYRbiIv4olzbf7dCxXr/85g7nV3
yuYNA00KsHFWRscrqkleQslkFet3I9kgRYRQXysJKIeOkLCF8sFtCh2CFx3PRMit
mc4YELTytBw/RWyFIcuSiO2hiXlW3eGSHVQR+YA3BU0bXar4Eiv2Z/n3gjG8CVkd
2xawHl98Z+6B3ylmlUjQ
=RKeE
-----END PGP SIGNATURE-----

--=-4ppgMENkhMc1yXNWIrjX--
