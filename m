From: Sven Eckelmann <sven@narfation.org>
Subject: Re: [PATCH 3/3] batman-adv: Add missing kerneldoc for extack
Date: Sun, 08 Oct 2017 09:29:17 +0200
Message-ID: <1655154.zJsG0lsWS3@sven-edge>
References: <20171007121853.6278-1-sven@narfation.org> <20171007122122.6470-1-sven@narfation.org> <20171007.205952.775593212999479324.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart4166471.q1eGAoD70L"; micalg="pgp-sha512"; protocol="application/pgp-signature"
Cc: b.a.t.m.a.n@lists.open-mesh.org, netdev@vger.kernel.org,
        dsahern@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:57292 "EHLO v3-1039.vlinux.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750997AbdJHH31 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 8 Oct 2017 03:29:27 -0400
In-Reply-To: <20171007.205952.775593212999479324.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart4166471.q1eGAoD70L
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"

On Samstag, 7. Oktober 2017 20:59:52 CEST David Miller wrote:
> From: Sven Eckelmann <sven@narfation.org>
> Date: Sat,  7 Oct 2017 14:21:22 +0200
> 
> > The parameter extack was added to batadv_softif_slave_add without adding
> > the kernel-doc for it. This caused kernel-doc warnings.
> > 
> > Signed-off-by: Sven Eckelmann <sven@narfation.org>
> > Cc: David Ahern <dsahern@gmail.com>
> 
> I'm happy to apply this but where are the other two patches of this
> series and the series header posting?

They are on the b.a.t.m.a.n@lists.open-mesh.org mailing list. And they deal 
with the "extack" compat problems of the out-of-tree module build.

Why were you cc'ed for the patch 3:
==================================

David Ahern and David Miller were involved in adding following changes to 
batman-adv:

* net: Add extack to ndo_add_slave
* net: Add extack to upper device linking

These were not posted to the batman-adv mailing list.

An automatic kernel-doc run on a build machine noticed a minor problem in the 
first patch. Since I was not involved in the original change (and have not 
checked what was discussed in the past about it), I could only guess how the 
kernel-doc should have looked like. But you, David Ahern or anyone else from 
netdev@... could have a different, more educated opinion about the correct 
documentation - this is why you were Cc'ed.


Why are you not Cc'ed on the patch 1+2:
======================================

The changes are about code which is not present in the upstream kernel. It 
only deals with changes required to build the extracted batman-adv module 
against a different kernel. These changes were required to get the "extack" 
stuff working on Linux 4.14 and below.

So, it is not really relevant for you but for some people on the 
b.a.t.m.a.n@lists.open-mesh.org mailing list. This is why everything 
(including the third patch) was send directly ("To:") to the mentioned mailing 
list.


Are you expected to apply this change:
=====================================

I was hoping that Simon is picking the patch up and forwards it do you in a 
proper pull request. But I would doubt that he has a big problem with you 
applying this single line kernel-doc change. At least it is less work for him 
and less extra noise on both mailing lists...

But feel free to tell us your preferred solution.

Kind regards,
	Sven
--nextPart4166471.q1eGAoD70L
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEEF10rh2Elc9zjMuACXYcKB8Eme0YFAlnZ080ACgkQXYcKB8Em
e0Z2wxAA12zqXHsQg3LlWV9SI/vd5TXFcRdFA00ruYXaH3LfDUSPB9i0diMSbHIM
w0zJr1oDumxeO/g/hJtpBMFB1MJv2ThSAg1YZC3QYyBqEs7jMxJTE2a98zz6zF0v
CraG0oayud20ZxGvCuY29Gb5PYMJbXIBskqa0jjs9kQebCBPLpPBXbwrQU8gIk93
eHi4rUXG+Cly0zU+U2VRZu2YaawPW2r3bar6NwziPDioP5JpF6tV3TLUxBuUcfZB
03bmSjovY0fZWbzFpGXZCqAAO8Y/cQk6fjCET7rJrOypAVt4mpCykcdT+WXL6wkz
06eNYzdTG4I74FsageHwkikw/lauJDtRxdpxK/9AzCP4mBAzugel95fY1H49EvoY
pa0Jk4n1WdXcLkBgpJKncwKm3ISgQSRRQyxXljQFaaZHR98a2TOGrInUBW1z5qJe
HoPAIOjbS2YAHw3UftwTFWFtTX/FS7gkDmiIlKW6t458Vu3XwLX/PlvFm6YkgSuY
hgE1KZq+pz07lnZOqK9eZJrbGqoDyVFiBk8g+iOUYBhoCa9CqaHlXJad/9d4MBZ1
HAellSUcSaH4xE2P0xH/Nfpr3i0dGzaDNUIMploi5H/zYYIMyNIOgawLd/B2PmB9
ae94jPTOS0gZafDLYGDFVyaO2hRCug5sIfysdlKHtT/PGGhpTpM=
=oLrj
-----END PGP SIGNATURE-----

--nextPart4166471.q1eGAoD70L--
