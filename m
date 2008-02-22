From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: 2.6.25-rc2-mm1 - several bugs and a crash
Date: Fri, 22 Feb 2008 01:52:53 +0100
Message-ID: <47BE1CE5.1030001@imap.cc>
References: <20080216002522.9c4bd0fb.akpm@linux-foundation.org> <47BC982C.7050402@imap.cc> <47BD6072.4000407@trash.net> <47BE1A03.30300@imap.cc>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigCCD2F034FE8C131B9A0DD061"
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <47BE1A03.30300@imap.cc>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigCCD2F034FE8C131B9A0DD061
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: quoted-printable

Am 22.02.2008 01:40 schrieb Tilman Schmidt:
>>
>>     [NETFILTER]: nf_conntrack: fix smp_processor_id() in preemptible c=
ode warning
>=20
> Yes, it does; and the system also survives substantially longer.
> (IOW, it hasn't crashed on me so far.)

Which of course it did the second after I sent off that mail. :-(
No message at all this time at the time of the crash, even though
I had "tail -f /var/log/messages" running in an ssh session.

So the nf_conntrack BUG is fixed, but the crash (and of course the
swapper "spinlock bad magic" BUG) persists.

--=20
Tilman Schmidt                          E-Mail: tilman@imap.cc
Bonn, Germany
Diese Nachricht besteht zu 100% aus wiederverwerteten Bits.
Unge=F6ffnet mindestens haltbar bis: (siehe R=FCckseite)


--------------enigCCD2F034FE8C131B9A0DD061
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.3rc1 (MingW32)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFHvhzmMdB4Whm86/kRAuBrAJ9l0FIXZ9jvWnVoxMJyliSMUoOs9gCfd7io
AsVKB8OH/pIgpWucpICt9hw=
=UIri
-----END PGP SIGNATURE-----

--------------enigCCD2F034FE8C131B9A0DD061--
