From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] IB/ipoib: move back the IB LL address into the hard
 header
Date: Tue, 11 Oct 2016 14:50:11 -0400
Message-ID: <9bed7085-949b-c68b-91ed-f930702a6a94@redhat.com>
References: <1dbd83dfe7f435eecc5bc460e901b47758280f30.1476206016.git.pabeni@redhat.com>
 <20161011173216.GA16892@obsidianresearch.com>
 <22f61258-9bcf-0adc-f23f-79a4f1d50c6a@redhat.com>
 <20161011180119.GB17319@obsidianresearch.com>
 <1476209407.448.9.camel@redhat.com>
 <073e0007-a43b-134d-ba7e-b290304be585@redhat.com>
 <20161011183019.GC20253@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="XRitH7f1gUPqXUnvAXoX2rXC8EHOspUQc"
Cc: Paolo Abeni <pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161011183019.GC20253-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--XRitH7f1gUPqXUnvAXoX2rXC8EHOspUQc
Content-Type: multipart/mixed; boundary="VeSQS6lJNj3Cphhis3xh1Hkex1NVlmXid";
 protected-headers="v1"
From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Cc: Paolo Abeni <pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Hal Rosenstock
 <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Message-ID: <9bed7085-949b-c68b-91ed-f930702a6a94-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] IB/ipoib: move back the IB LL address into the hard
 header
References: <1dbd83dfe7f435eecc5bc460e901b47758280f30.1476206016.git.pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
 <20161011173216.GA16892-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
 <22f61258-9bcf-0adc-f23f-79a4f1d50c6a-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
 <20161011180119.GB17319-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
 <1476209407.448.9.camel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
 <073e0007-a43b-134d-ba7e-b290304be585-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
 <20161011183019.GC20253-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
In-Reply-To: <20161011183019.GC20253-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>

--VeSQS6lJNj3Cphhis3xh1Hkex1NVlmXid
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 10/11/2016 2:30 PM, Jason Gunthorpe wrote:
> On Tue, Oct 11, 2016 at 02:17:51PM -0400, Doug Ledford wrote:
>=20
>> Well, not exactly.  Even if we put 65520 into the scripts, the kernel
>> will silently drop it down to 65504.  It actually won't require anyone=

>> change anything, they just won't get the full value.  I experimented
>> with this in the past for other reasons and an overly large MTU settin=
g
>> just resulted in the max MTU.  I don't know if that's changed, but if =
it
>> still works that way, this is much less of an issue than it might
>> otherwise be.
>=20
> So it is just docs and relying on PMTU? That is not as bad..
>=20
> Still would be nice to avoid if at all possible..

I agree, but we have a test getting ready to commence.  We'll know
shortly how much the reduced MTU effects things because they aren't
going to alter any of their setup, just put the new kernel in place, and
see what happens.


--=20
Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    GPG Key ID: 0E572FDD


--VeSQS6lJNj3Cphhis3xh1Hkex1NVlmXid--

--XRitH7f1gUPqXUnvAXoX2rXC8EHOspUQc
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJX/TRjAAoJELgmozMOVy/dWZkP/RQGuS33dAd9MDKr61HfF4Ss
t6TBu74GyIzhuIZ+FfbSdeRbQzzeoKkQBW/rTfIUPzsZolo/doQfNTX+uqZdNgqm
53RcSK8g59ScUgRHcgWDHeAapM2Xzq4y/JHgekAHaBa6EpUYxZnUcrU9cQSmM58F
D1g+dj+iGlunsO3vyqHAnA6850fz2a5vTxiYy4r1IXVE2qkwDTmkNpwUgzGBMmRx
W95BGnOWc4YeUsDUlTbTBM/GockR7xZSp5A1TACFKjmnbts6JvTPV25rQxE/K1aN
4DGc7HtbPoLMgOL6qLDpJzjKINEeqRvcAvXEg7D2Ewy+PEWH1KEBuxF97odtmdin
M9meTmtH1uKsbJgwwqMj4MJ1UqghtqgIUN1nK/2zijBan5SWb291xdv37xx32JDS
SQKyjuncES6PewfiTu1gMQg3UMY32hjKbeKxX+Oh3ItRf72zHyLrTejb4Ui2uCU/
Cr9MWuXV6nJjTVxyBBgnJaKaAX0k/3ifrl6cnioHEfKxVklyHePWpAbQi0fAwBPZ
ytory4D/Kbtclri4u6zoGsGf9/+qmlibY2jj1mxw+TOtYNQf/RVwq2rQYKEGwqb1
hMmI93Z/ZJb9MnT3YaZxUdUP1A4n3WbsHXJw6Tz/LDScZkJBJqEovYJROcq0j3zx
4zjr1FeCnDNp+GKRBTaq
=XVsW
-----END PGP SIGNATURE-----

--XRitH7f1gUPqXUnvAXoX2rXC8EHOspUQc--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
