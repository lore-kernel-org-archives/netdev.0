From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] CHOKe flow scheduler (0.11)
Date: Thu, 03 Feb 2011 02:59:12 +0100
Message-ID: <1296698352.4434.4.camel@edumazet-laptop>
References: <20110113092706.154748c2@s6510>
	 <1294951069.3403.11.camel@edumazet-laptop> <20110113153436.70d3c0a3@s6510>
	 <4D305598.1010207@trash.net> <4D3055C2.3060807@trash.net>
	 <1295015043.3937.20.camel@edumazet-laptop>
	 <20110114154521.54cc8ef5@nehalam>
	 <1295077542.3977.20.camel@edumazet-laptop>
	 <20110117092532.7d5f5a5b@nehalam>
	 <1295286851.3335.36.camel@edumazet-laptop>
	 <20110118110634.7386c757@nehalam> <1295379257.9097.9.camel@edumazet-laptop>
	 <20110120093838.43f9f9b1@nehalam>
	 <1295547589.2825.497.camel@edumazet-laptop>
	 <1295563611.2613.41.camel@edumazet-laptop>
	 <20110202172110.7ea96e19@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:39579 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754467Ab1BCB7U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Feb 2011 20:59:20 -0500
Received: by wwa36 with SMTP id 36so703439wwa.1
        for <netdev@vger.kernel.org>; Wed, 02 Feb 2011 17:59:19 -0800 (PST)
In-Reply-To: <20110202172110.7ea96e19@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 02 f=C3=A9vrier 2011 =C3=A0 17:21 -0800, Stephen Hemminger =
a =C3=A9crit :
> Subject: sched: CHOKe flow scheduler
>=20
> CHOKe ("CHOose and Kill" or "CHOose and Keep") is an alternative
> packet scheduler based on the Random Exponential Drop (RED) algorithm=
=2E
>=20
> The core idea is:
>   For every packet arrival:
>   	Calculate Qave
> 	if (Qave < minth)=20
> 	     Queue the new packet
> 	else=20
> 	     Select randomly a packet from the queue=20
> 	     if (both packets from same flow)
> 	     then Drop both the packets
> 	     else if (Qave > maxth)
> 	          Drop packet
> 	     else
> 	       	  Admit packet with proability p (same as RED)
>=20
> See also:
>   Rong Pan, Balaji Prabhakar, Konstantinos Psounis, "CHOKe: a statele=
ss active
>    queue management scheme for approximating fair bandwidth allocatio=
n",=20
>   Proceeding of INFOCOM'2000, March 2000.
>=20
> Help from:
>      Eric Dumazet <eric.dumazet@gmail.com>
>      Patrick McHardy <kaber@trash.net>
>=20
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>=20
> ---
> 0.11 - incorporates Eric's change to use rxhash
>=20
> =20

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Thanks Stephen !


