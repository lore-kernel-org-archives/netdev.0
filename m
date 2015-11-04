From: Wolfgang Walter <linux@stwm.de>
Subject: Re: [PATCH net-next] ipv6: gro: support sit protocol
Date: Wed, 04 Nov 2015 18:05:55 +0100
Message-ID: <3441744.PdBCeOO15u@stwm.de>
References: <1438621878-1113072-1-git-send-email-tom@herbertland.com> <2511200.aYIar34voW@stwm.de> <1446649987.4184.22.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, Jerry Chu <hkchu@google.com>,
	JesseGross <jesse@nicira.com>, Tom Herbert <tom@herbertland.com>,
	netdev <netdev@vger.kernel.org>, kernel-team@fb.com,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailin.studentenwerk.mhn.de ([141.84.225.229]:58050 "EHLO
	email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932365AbbKDRF5 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Nov 2015 12:05:57 -0500
In-Reply-To: <1446649987.4184.22.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Mittwoch, 4. November 2015, 07:13:07 schrieb Eric Dumazet:
> On Wed, 2015-11-04 at 15:09 +0100, Wolfgang Walter wrote:
> > Yes, maybe igb has a problem sending a gro-packet if it is an isata=
p in
> > gre.
> We might detect this condition properly from igb ndo_features_check
> method.
>=20
> It currently uses plain passthru_features_check()
>=20
> > igb has no problem sending gro-packets which are pure isatap or whi=
ch are
> > ipv4 (tcp/udp) in gre with 4.1.12 + these patches.
> >=20
> > And it had no problem with 4.1.11 with isatap in gre.
> >=20
> > Disabling gso for the interface does help.
>=20
> My patch was aimed for 4.4, not sure about backports to old kernels..=
=2E

I know. I cannot test 4.4 (or net-next) on that router, though, as I do=
n't=20
have easy physical access to it if it crashes or I loose network connec=
tivity.=20
=46or such tests I must send someone in situ.

As 4.4 will be the next longterm kernel I definitivly will do that for =
4.4-rc2=20
or 4.4-rc3.

I think your patch is correct for 4.1 in the sense that ISATAP is corre=
ctly=20
handled. Only SIT in GRE triggers this and if it is indeed igb I will s=
ee it=20
probably in 4.4 ;-), too.

I now tested an unmodified 4.1.12 and it shows no problems.


Regards,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
