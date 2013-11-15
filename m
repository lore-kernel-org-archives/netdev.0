From: Thomas Haller <thaller@redhat.com>
Subject: Re: [patch net-next RFC 2/2] ipv6 addrconf: introduce
 IFA_F_MANAGETEMPADDR to tell kernel to manage temporary addresses
Date: Fri, 15 Nov 2013 19:04:25 +0100
Message-ID: <1384538665.10852.31.camel@rh1.brq.redhat.com>
References: <1384181359-23199-1-git-send-email-jiri@resnulli.us>
	 <1384181359-23199-3-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-GVaQCdXiBbuwc1xUWo5/"
Cc: netdev@vger.kernel.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	stephen@networkplumber.org, hannes@stressinduktion.org,
	vyasevich@gmail.com, dcbw@redhat.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50792 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751178Ab3KOSFN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Nov 2013 13:05:13 -0500
In-Reply-To: <1384181359-23199-3-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-GVaQCdXiBbuwc1xUWo5/
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2013-11-11 at 15:49 +0100, Jiri Pirko wrote:
> Creating an address with this flag set will result in kernel taking care
> of temporary addresses in the same way as if the address was created by
> kernel itself (after RA receive). This allows userspace applications
> implementing the autoconfiguration (NetworkManager for example) to
> implement ipv6 addresses privacy.

Hi,

I think, addrconf_prefix_rcv should not do anything if user created ones
already exist.

"Already exist" could mean, a user created address with:
- the same IP address and MANAGETEMPADDR flag
- the same IP address
- the same /64 prefix and MANAGETEMPADDR flag
- the same /64 prefix
(??)

Of course, the user should disable accept_ra, if he wants to manage
the temporary addresses himself. But it would still be more correct
to check that prefixes from RA do not interfere.


Thomas



--=-GVaQCdXiBbuwc1xUWo5/
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIcBAABAgAGBQJShmIpAAoJEKHCmQ/SsOFdNBsQAKXpOA0UA/ffu/GNMs5u81V/
Ezj3mcM58G3yi7I8qomBeXfTmuyrEM81UmcKOSIij/7c7HVLsS27vsafospaK2c+
kwjF783ff9WL8imU1llmfLcCsO0JYCRq7Lr23ydWpXReeEaA0MWsVibaPNFMbvuq
uS2Ii1zYZqSJI+U+IZxROcavgXi8SjQ0+6BcUno67fGp8f/NWd1ckGCOpuJQKYlc
3AG5d5XwNbl7e1gk6+AhayxpXa5jq6tuQtRQaBmydZIh2fbolrXuGd/Uu1Xgb2sD
4Xer/FvsWhrtoPVdcz4vbetBSZaF88fMaMK8Uw7uqfCVXFMl1c1LPOjP7CStuH4e
uJz656fG/5bme6nMMCsmwzRW4J5GEA8jE2TUZA4MaR5s0LIJ5hyTp6nQ/3bKdO+z
4oPf5IBRXjyGWX4t+7laS2Q/3TgZr0i1DBlauPqgNtd+BzngBG9BRGph7tDeJHZ/
VbDBnik9u0OuTyJ+DDSpgWji0zUqJMtCRsnN+gYceg5fYbAOVnMHNC9FGJhB23W8
tcd7UHL8NV9tonL+4Hly0u8ByEE/XTN7W5TWkhflkbbnhh3x0EyKUdrMvjGxYccG
eRnaU+yYpL7t2R4c72vN6+b9sSLM3V7Bu/xQ1P7F+wYp4iVwvZSmrHulJt+HVEWs
wOYeKbxYUcvVooidKG/V
=UGg7
-----END PGP SIGNATURE-----

--=-GVaQCdXiBbuwc1xUWo5/--
