From: Gregory Haskins <gregory.haskins@gmail.com>
Subject: Re: [GIT PULL] AlacrityVM guest drivers for 2.6.33
Date: Tue, 22 Dec 2009 14:47:30 -0500
Message-ID: <4B312252.4040009@gmail.com>
References: <4B1D4F29.8020309@gmail.com> <20091218215107.GA14946@elte.hu> <4B2F9582.5000002@gmail.com> <20091222075742.GB26467@elte.hu> <4B3103B4.4070708@gmail.com> <4B3115C1.4070303@redhat.com> <4B311ADA.4000700@gmail.com> <4B311D20.7020400@redhat.com> <4B311ECB.6040205@gmail.com> <4B312042.7010804@redhat.com> <4B3120E2.7070307@gmail.com> <4B312155.7040308@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigE0499CCAC912016D7F3A4A46"
Cc: Ingo Molnar <mingo@elte.hu>, kvm@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	torvalds@linux-foundation.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	"alacrityvm-devel@lists.sourceforge.net"
	<alacrityvm-devel@lists.sourceforge.net>
To: Avi Kivity <avi@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f211.google.com ([209.85.217.211]:41365 "EHLO
	mail-gx0-f211.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754784AbZLVTrf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2009 14:47:35 -0500
In-Reply-To: <4B312155.7040308@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigE0499CCAC912016D7F3A4A46
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 12/22/09 2:43 PM, Avi Kivity wrote:
> On 12/22/2009 09:41 PM, Gregory Haskins wrote:
>>
>>> It means that kvm locking suddenly affects more of the kernel.
>>>
>>>     =20
>> Thats ok.  This would only be w.r.t. devices that are bound to the KVM=

>> instance anyway, so they better know what they are doing (and they do)=
=2E
>>
>>   =20
>=20
> It's okay to the author of that device.  It's not okay to the kvm
> developers who are still evolving the locking and have to handle all
> devices that use xinterface.

Perhaps, but like it or not, if you want to do in-kernel you need to
invoke backends.  And if you want to invoke backends, limiting it to
thread wakeups is, well, limiting.  For one, you miss out on that
exploit I mentioned earlier which can help sometimes.

Besides, the direction that Marcelo and I left the mmio/pio bus was that
it would go lockless eventually, not "more lockful" ;)

Has that changed?  I honestly haven't followed whats going on in the
io-bus code in a while.

-Greg



--------------enigE0499CCAC912016D7F3A4A46
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAksxIlIACgkQP5K2CMvXmqHixgCdEafS1WfHfXOoJ+5gQVBDOnHo
YywAn0cPxfpSdKx+ezbd3B9DW7hiqpqu
=sloy
-----END PGP SIGNATURE-----

--------------enigE0499CCAC912016D7F3A4A46--
