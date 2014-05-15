From: Stefan Bader <stefan.bader@canonical.com>
Subject: Re: [Xen-devel] xen-netfront possibly rides the rocket too often
Date: Thu, 15 May 2014 11:03:01 +0200
Message-ID: <537482C5.4060602@canonical.com>
References: <537262AB.5010408@canonical.com> <5373C8D4.2010803@citrix.com>	<5373CCD1.4050509@citrix.com> <1721040118.20140515103816@eikelenboom.it>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="6PC0qKsm7iOpkMG0tJehurv3XuDCVDxiO"
Cc: xen-devel@lists.xenproject.org, netdev <netdev@vger.kernel.org>
To: Sander Eikelenboom <linux@eikelenboom.it>,
	Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:38109 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751828AbaEOJDE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 05:03:04 -0400
In-Reply-To: <1721040118.20140515103816@eikelenboom.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--6PC0qKsm7iOpkMG0tJehurv3XuDCVDxiO
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 15.05.2014 10:38, Sander Eikelenboom wrote:
>=20
> Wednesday, May 14, 2014, 10:06:41 PM, you wrote:
>=20
>> On 14/05/14 20:49, Zoltan Kiss wrote:
>>> On 13/05/14 19:21, Stefan Bader wrote:
>>>> Since I am not deeply familiar with the networking code, I wonder
>>>> about two things:
>>>> - is there something that should limit the skb data length from all =
frags
>>>>    to stay below the 64K which the definition of MAX_SKB_FRAGS hints=
?
>>> I think netfront should be able to handle 64K packets at most.
>>>> - is multiple frags having offsets expected?
>>> Yes, since compound pages a frag could over the 4K page boundary. The=

>>> problem is, that in the netback/front protocol the assumption is that=

>>> every slot is a single page, because grant operations could be done o=
nly
>>> on a 4K page. And every slot ends up as a frag (expect maybe the firs=
t,
>>> it can happen it is grant copied straight to the linear buffer),
>>> therefore the frontend cannot send an skb which occupies more than
>>> MAX_SKB_FRAGS individual 4k page.
>>> The problem is known for a while, the solution is not, unfortunately.=

>=20
>> I think the worst case scenario is when every frag and the linear buff=
er=20
>> contains 2 bytes, which are overlapping a page boundary (that's=20
>> (17+1)*2=3D36 so far), plus 15 of them have a 4k page in the middle of=
=20
>> them, so, a 1+4096+1 byte buffer can span over 3 page. That's 51=20
>> individual pages.
>> With the previous grant copy implementation there would be the option =
to=20
>> modify backend and coalesce everything into a well formed skb. That=20
>> would be a minor change there. But with grant mapping it's harder.
>> Slots of compound pages could be mapped to adjacent pages to Dom0, may=
be=20
>> somehow you can present them as compound pages in Dom0 as well. But in=
=20
>> MFN space they wouldn't be contiguous, you need SWIOTLB or use IOMMU t=
o=20
>> hide that from the devices. Plus, what happens when you can't find=20
>> adjacent pending slots?
>> I think we would be better off at the moment with trying to compact=20
>> these skbs a bit. Usually they overflow the limit by one or two, which=
=20
>> means we should reallocate one or two frag, or the linear buffer to=20
>> decrease the number of 4K pages used.
>=20
> How does virtio-net handle this, the would probably have ran into the s=
ame problems ?

Maybe, though it seems not too many things cause this kind of traffic and=
 then I
could not say whether they have to handle a limited set of ring pages, to=
o. But
its something to keep in mind when digging deeper into it.

-Stefan
>=20
> --
> Sander
>=20
>> Zoli
>=20
>=20
>=20
>=20
> _______________________________________________
> Xen-devel mailing list
> Xen-devel@lists.xen.org
> http://lists.xen.org/xen-devel
>=20



--6PC0qKsm7iOpkMG0tJehurv3XuDCVDxiO
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCgAGBQJTdILFAAoJEOhnXe7L7s6jph4P/2WCcKOoeE/fYjgAS2D3PNDn
XaVxjUPrBzRGtMiX+ttFT+Nx1x2u3uhAjxcs9IOkxBifzQ3hdRn5CLdlXotQYpFn
3QN3r2+exvuTocBiJBGmVhZjRUS0B6wOVPHhyhtvjfrty3iZF3rSGTkkFyLO/fFO
wKDzNtm2g6sLB4XOFGMjjwtV5f4IbqKLDkka2KEAoPeA2DTImyO05vJ+5gSW1QZO
vEOMnR6yEB86OoUTo7OlZwyb3sOkDGQNoTFqPiNwMPJCr+cV2lgm/WY1HwHmq/zM
akEywhVN3FhdvdItCQ2Mygv9JvmIsvLUleXjKBYrOw1wIA2TmALuXVpsZAU9DkdC
urBKVf+Fk7p2Vf3ZpLTdOQ74VDFOxy5Wd32bVZlexluibSzMyPl0+t3RhXN4y04S
TrLtwVegye6WYFVSZ2pM8630OPPLyvjr0fQ/RuT9u5hEk5z/ZFPPvR+H9YL99R2j
bTT32WuSod4pQI7Rc3p+cgEVIPtKsCHcKWQwk6sgJQwY4asCyvmPNf3BsjNSGTlP
vpxZLhpskTEWnHbbeb1/kX/6RQ71GxGquTiwknnWK2eMMlQe9gR9b8Ur2K2sG8Wp
wCqPsz/28Cy/PFcqsGhesDdosKyxI38peWQ25otE+qa/1IBulqzfTYYlhWgccSx7
0aOtXlidkYzyMkpoHaTq
=rGjx
-----END PGP SIGNATURE-----

--6PC0qKsm7iOpkMG0tJehurv3XuDCVDxiO--
