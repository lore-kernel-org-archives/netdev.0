From: Gregory Haskins <ghaskins@novell.com>
Subject: Re: [RFC PATCH v2 00/19] virtual-bus
Date: Fri, 05 Jun 2009 08:54:24 -0400
Message-ID: <4A291580.90305@novell.com>
References: <20090409155200.32740.19358.stgit@dev.haskins.net> <49E0C93E.5030205@redhat.com> <4A28172D.6010906@gmail.com> <200906051425.02924.rusty@rustcorp.com.au> <4A290800.1030803@novell.com> <4A29154B.2000600@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig8D93EF3B98F81FFA65C28AEC"
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	linux-kernel@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, anthony@codemonkey.ws,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	bhutchings@solarflare.com, andi@firstfloor.org, gregkh@suse.de,
	herber@gondor.apana.org.au, chrisw@sous-sol.org,
	shemminger@vyatta.com
To: Avi Kivity <avi@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from victor.provo.novell.com ([137.65.250.26]:35214 "EHLO
	victor.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750999AbZFEMyd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jun 2009 08:54:33 -0400
In-Reply-To: <4A29154B.2000600@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig8D93EF3B98F81FFA65C28AEC
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: quoted-printable

Avi Kivity wrote:
> Gregory Haskins wrote:
>>> @@ -1,6 +1,6 @@
>>>  config LGUEST
>>>      tristate "Linux hypervisor example code"
>>> -    depends on X86_32 && EXPERIMENTAL && !X86_PAE && FUTEX
>>> +    depends on X86_32 && EXPERIMENTAL && !X86_PAE && EVENTFD
>>>      =20
>>
>> Note to self:  we probably need a similar line in KVM now.
>>
>>  =20
>
> 'select EVENTFD' is more appropriate.
>
>

Yeah, I was thinking the same...


--------------enig8D93EF3B98F81FFA65C28AEC
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEARECAAYFAkopFYUACgkQlOSOBdgZUxm4MACfWX4f1R457GUaKLhvV5PpDBla
d8QAnAqUiNQvt+u87l9/yfhTnFyVe469
=4kST
-----END PGP SIGNATURE-----

--------------enig8D93EF3B98F81FFA65C28AEC--
