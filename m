From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] RFC2988bis + taking RTT sample from 3WHS for the
 passive open side
Date: Wed, 08 Jun 2011 16:57:50 -0700
Message-ID: <1307577470.8149.3096.camel@tardy>
References: <BANLkTikpmXMpuTmgejsgisV9O2fP1i7VLnUO3bcYLSU0+iXJVg@mail.gmail.com>
	 <BANLkTimo_fbezdX2evKt0pAg0N+DSJQeSR6NoHLus=Z40WLkHg@mail.gmail.com>
	 <1307576361.3980.26.camel@edumazet-laptop>
	 <20110608.164433.1248144748353908346.davem@davemloft.net>
Reply-To: rick.jones2@hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, hkchu@google.com, hagen@jauu.net,
	tsunanet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:41847 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754763Ab1FHX55 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2011 19:57:57 -0400
In-Reply-To: <20110608.164433.1248144748353908346.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-06-08 at 16:44 -0700, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 09 Jun 2011 01:39:21 +0200
>=20
> > Le mercredi 08 juin 2011 =C3=A0 15:26 -0700, Jerry Chu a =C3=A9crit=
 :
> >> It just occurred to me now that initRTO is being reduced, both TCP=
_SYN_RETRIES
> >> and TCP_SYNACK_RETRIES should be bumped up a bit, to e.g., 7 (?) t=
o meet the
> >> 3 minutes R2 requirement per RFC1122.
> >>=20
> >> If you agree, I will submit another patch.
> >=20
> > Good catch, but no RFC lowered yet this 3 minutes requirement ?
>=20
> I host my email on other planets, please do not break this.

As the RTT to Mars is a minimum of 500 seconds and a maximum of 2500,
and a minimum of 276 seconds for Venus, your software must already be
successfully dealing with TCP connection timeouts less than the RTT to
the planets nearest to Earth, so there should be no need to maintain 3
minutes anyway :)

rick jones
http://c2.com/cgi/wiki?LightSpeedLag
http://ase.tufts.edu/cosmos/print_chapter.asp?id=3D1

