From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net] e1000e: enable ECC on I217/I218 to catch packet buffer
 memory errors
Date: Mon, 28 Jan 2013 04:45:56 -0800
Message-ID: <1359377156.2255.74.camel@jtkirshe-mobl>
References: <1359369828-13663-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <CA+5PVA5i-jVrjtO1Lbm=DSWk0o+C6P87kqKUqNnbThafFF2o0A@mail.gmail.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-GFcAsQBZat5KSVWzJOCc"
Cc: davem@davemloft.net, Bruce Allan <bruce.w.allan@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	stable@vger.kernel.org
To: Josh Boyer <jwboyer@gmail.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <CA+5PVA5i-jVrjtO1Lbm=DSWk0o+C6P87kqKUqNnbThafFF2o0A@mail.gmail.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-GFcAsQBZat5KSVWzJOCc
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2013-01-28 at 07:38 -0500, Josh Boyer wrote:
> On Mon, Jan 28, 2013 at 5:43 AM, Jeff Kirsher
> <jeffrey.t.kirsher@intel.com> wrote:
> > From: Bruce Allan <bruce.w.allan@intel.com>
> >
> > In rare instances, memory errors have been detected in the internal pac=
ket
> > buffer memory on I217/I218 when stressed under certain environmental
> > conditions.  Enable Error Correcting Code (ECC) in hardware to catch bo=
th
> > correctable and uncorrectable errors.  Correctable errors will be handl=
ed
> > by the hardware.  Uncorrectable errors in the packet buffer will cause =
the
> > packet to be received with an error indication in the buffer descriptor
> > causing the packet to be discarded.  If the uncorrectable error is in t=
he
> > descriptor itself, the hardware will stop and interrupt the driver
> > indicating the error.  The driver will then reset the hardware in order=
 to
> > clear the error and restart.
> >
> > Both types of errors will be accounted for in statistics counters.
> >
> > Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> > Cc: <stable@vger.kernel.org> # 3.5.x & 3.6.x
>=20
> 3.5.x is maintained by Canonical, not officially as a stable kernel (I
> have no idea why).  3.6.x isn't maintained any longer.
>=20
> Is this applicable to 3.4.x and 3.7.x?

It is applicable to 3.7.x, not sure if it applicable to 3.4.x.

--=-GFcAsQBZat5KSVWzJOCc
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAABCgAGBQJRBnMEAAoJEOVv75VaS+3OZrsP/22DujMbWX+ROMDmOUoS3y9Z
kVtnf8YOFkOPY/SFOakf++HKae5CtFvWb4Ucj//7v8V7JukaEvP6TGrPmIYHHcDA
pLrHxE+m1dprAFrnxACvEua8FJnyXYrzfowlKjjok/A02tNhmAZlbEMCIGgc/QB7
UkQxt0hBrdsAtkbSy6kPsplEahjLghvkv7vlR1vYkXCrZs0tQoqbtsLqSPbHX6K5
zC9D7H3O0EOtzuAk300V1KYW9kPMrUPZNUi4JgCpanuPyxVt0am/mZLy//MKcZGn
wNttdVhXnsOMGM1Vhwfz3145OHhCrOE1WbZyNzfwnjesPX38j/0kNRcrqQg9q+Jr
jmvEKyL4/JvQiVq1waXjvq5o91ghz7XjK7AIsENPSDox1oSWofFTZ/l2ScV8MO5N
eHtS1uYN2kIKQsXpiVSh+13jfFPtOQnFWPlHrkxnFdJbpgEE19yZHTETIOqnZl0P
p0pxvFKWNI1TeTVmMrG/MxLtWKDV2kTHlasq5kZhZPMvvVlX0h3yNeuZbpDBFn0d
nZSVJfrgb2bG6ZUL14dAmstwM4z/dDzOXbV4qaPNZfnLVJ+9CVzZRUvcl+gdlBM+
/1KGvbyhzizdk9jAk0djcWmYnfEDz+9aiCTIa1/NmNCAN2dj9Svto6nNg4r6YI5X
8d5trXi7YsT1YL2AfwWL
=/gLH
-----END PGP SIGNATURE-----

--=-GFcAsQBZat5KSVWzJOCc--
