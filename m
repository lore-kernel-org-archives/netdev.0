From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] RFC2988bis + taking RTT sample from 3WHS for the
 passive open side
Date: Wed, 08 Jun 2011 16:59:36 -0700 (PDT)
Message-ID: <20110608.165936.858380505498163552.davem@davemloft.net>
References: <1307576361.3980.26.camel@edumazet-laptop>
	<20110608.164433.1248144748353908346.davem@davemloft.net>
	<1307577470.8149.3096.camel@tardy>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, hkchu@google.com, hagen@jauu.net,
	tsunanet@gmail.com, netdev@vger.kernel.org
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58717 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755372Ab1FHX7o convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2011 19:59:44 -0400
In-Reply-To: <1307577470.8149.3096.camel@tardy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Rick Jones <rick.jones2@hp.com>
Date: Wed, 08 Jun 2011 16:57:50 -0700

> On Wed, 2011-06-08 at 16:44 -0700, David Miller wrote:
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Thu, 09 Jun 2011 01:39:21 +0200
>>=20
>> > Le mercredi 08 juin 2011 =E0 15:26 -0700, Jerry Chu a =E9crit :
>> >> It just occurred to me now that initRTO is being reduced, both TC=
P_SYN_RETRIES
>> >> and TCP_SYNACK_RETRIES should be bumped up a bit, to e.g., 7 (?) =
to meet the
>> >> 3 minutes R2 requirement per RFC1122.
>> >>=20
>> >> If you agree, I will submit another patch.
>> >=20
>> > Good catch, but no RFC lowered yet this 3 minutes requirement ?
>>=20
>> I host my email on other planets, please do not break this.
>=20
> As the RTT to Mars is a minimum of 500 seconds and a maximum of 2500,
> and a minimum of 276 seconds for Venus, your software must already be
> successfully dealing with TCP connection timeouts less than the RTT t=
o
> the planets nearest to Earth, so there should be no need to maintain =
3
> minutes anyway :)

This just proves that the stickler for details can ruin any joke, sigh.=
=2E.
:-)
