From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] RFC2988bis + taking RTT sample from 3WHS for the
 passive open side
Date: Thu, 09 Jun 2011 01:39:21 +0200
Message-ID: <1307576361.3980.26.camel@edumazet-laptop>
References: <1307509203-30973-1-git-send-email-hkchu@google.com>
	 <1307550654.3057.70.camel@edumazet-laptop>
	 <BANLkTikpmXMpuTmgejsgisV9O2fP1i7VLnUO3bcYLSU0+iXJVg@mail.gmail.com>
	 <BANLkTimo_fbezdX2evKt0pAg0N+DSJQeSR6NoHLus=Z40WLkHg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Hagen Paul Pfeifer <hagen@jauu.net>, tsunanet@gmail.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jerry Chu <hkchu@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:35690 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754763Ab1FHXj0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2011 19:39:26 -0400
Received: by wwa36 with SMTP id 36so1093831wwa.1
        for <netdev@vger.kernel.org>; Wed, 08 Jun 2011 16:39:25 -0700 (PDT)
In-Reply-To: <BANLkTimo_fbezdX2evKt0pAg0N+DSJQeSR6NoHLus=Z40WLkHg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 08 juin 2011 =C3=A0 15:26 -0700, Jerry Chu a =C3=A9crit :
> Eric,
>=20
> It just occurred to me now that initRTO is being reduced, both TCP_SY=
N_RETRIES
> and TCP_SYNACK_RETRIES should be bumped up a bit, to e.g., 7 (?) to m=
eet the
> 3 minutes R2 requirement per RFC1122.
>=20
> If you agree, I will submit another patch.
>=20

Good catch, but no RFC lowered yet this 3 minutes requirement ?



