From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: dynticks + iptables almost stops the boot process [was: Re: 2.6.20-rc6-mm3]
Date: Wed, 07 Feb 2007 00:12:23 +0100
Message-ID: <45C90B57.90104@imap.cc>
References: <20070131215241.GB2890@inferi.kami.home> <20070131232130.GC4137@inferi.kami.home> <1170358572.29240.292.camel@localhost.localdomain> <1170360101.29240.297.camel@localhost.localdomain> <20070201211137.GA2830@inferi.kami.home> <1170369202.29240.339.camel@localhost.localdomain> <20070202191802.GA4262@inferi.kami.home> <1170448034.29240.364.camel@localhost.localdomain> <20070202204344.GB4262@inferi.kami.home> <20070206164826.GA3491@elte.hu> <20070206192840.GB2971@inferi.kami.home>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig078781D7F46D04E8339CF8CB"
To: Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>,
	Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org,
	mingo@redhat.com, netdev@vger.kernel.org,
	netfilter-devel@lists.netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5.smtp.messagingengine.com ([66.111.4.29]:48243 "EHLO
	out5.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1030556AbXBFXLp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Feb 2007 18:11:45 -0500
In-Reply-To: <20070206192840.GB2971@inferi.kami.home>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig078781D7F46D04E8339CF8CB
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Am 06.02.2007 20:28 schrieb Mattia Dongili:
> On Tue, Feb 06, 2007 at 05:48:26PM +0100, Ingo Molnar wrote:
>> Could you try the patch below? The RCU serialization code (a rare call=
=20
>> but can be common in some types of setups) has a nasty implicit=20
>> dependency on the HZ tick - which until now was a hidden wart but beca=
me=20
>> an explicit bug under dynticks. Maybe this is what is slowing down you=
r=20
>> box.

I have the same problem (huge delay when loading iptables) with
2.6.20-rc6-mm3, and for me this patch did fix it.

> No, not this. Anyway the last patch Thomas forwarded does fix the
> problem.

Which one would that be? I might try it for comparison.

Thanks,
Tilman

--=20
Tilman Schmidt                          E-Mail: tilman@imap.cc
Bonn, Germany
Diese Nachricht besteht zu 100% aus wiederverwerteten Bits.
Unge=F6ffnet mindestens haltbar bis: (siehe R=FCckseite)


--------------enig078781D7F46D04E8339CF8CB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.3rc1 (MingW32)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFFyQtfMdB4Whm86/kRAh1SAJ4nD7AUYhg1gU7UloR588LGaO0L+wCeO2un
CImLLx8g+vh7yfduSEgwfXU=
=YkNg
-----END PGP SIGNATURE-----

--------------enig078781D7F46D04E8339CF8CB--
