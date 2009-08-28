From: Gregory Haskins <gregory.haskins@gmail.com>
Subject: Re: [PATCHv5 1/3] mm: export use_mm/unuse_mm to modules
Date: Fri, 28 Aug 2009 11:31:30 -0400
Message-ID: <4A97F852.6060505@gmail.com>
References: <cover.1251388414.git.mst@redhat.com> <20090827160656.GB23722@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig1C5BA6B72C76D6CD23C7D55F"
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
 kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu,
 linux-mm@kvack.org, hpa@zytor.com, Rusty Russell <rusty@rustcorp.com.au>,
 s.hetze@linux-ag.com
To: "Michael S. Tsirkin" <mst@redhat.com>, akpm@linux-foundation.org
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20090827160656.GB23722@redhat.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig1C5BA6B72C76D6CD23C7D55F
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Michael S. Tsirkin wrote:
> vhost net module wants to do copy to/from user from a kernel thread,
> which needs use_mm (like what fs/aio has).  Move that into mm/ and
> export to modules.


Michael, Andrew,

I am just curious: Is there any technical reason why a kthread cannot
have a long-term use_mm() in effect? (Assuming this makes sense for the
design, of course).  For the cases there we know the kthread will always
service the same context (such as with venettap/vhost, it may make sense
to do a use_mm() at init time and just leave it until the thread exits.
 Will this break anything?

Kind Regards,
-Greg


--------------enig1C5BA6B72C76D6CD23C7D55F
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkqX+FIACgkQP5K2CMvXmqGsNACghgmvgLjfVfN25itYVCnOSH4G
CIwAn1VdFGYr8TJCQTlY3E1yjibfYjMF
=3B87
-----END PGP SIGNATURE-----

--------------enig1C5BA6B72C76D6CD23C7D55F--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
