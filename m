From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] CHOKe flow scheduler (0.11)
Date: Wed, 02 Feb 2011 20:53:03 -0800 (PST)
Message-ID: <20110202.205303.104058817.davem@davemloft.net>
References: <1295563611.2613.41.camel@edumazet-laptop>
	<20110202172110.7ea96e19@nehalam>
	<1296698352.4434.4.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, kaber@trash.net, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44744
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755367Ab1BCEw2 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Feb 2011 23:52:28 -0500
In-Reply-To: <1296698352.4434.4.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 03 Feb 2011 02:59:12 +0100

> Le mercredi 02 f=E9vrier 2011 =E0 17:21 -0800, Stephen Hemminger a =E9=
crit :
>> Subject: sched: CHOKe flow scheduler
>>=20
>> CHOKe ("CHOose and Kill" or "CHOose and Keep") is an alternative
>> packet scheduler based on the Random Exponential Drop (RED) algorith=
m.
>>=20
>> The core idea is:
>>   For every packet arrival:
>>   	Calculate Qave
>> 	if (Qave < minth)=20
>> 	     Queue the new packet
>> 	else=20
>> 	     Select randomly a packet from the queue=20
>> 	     if (both packets from same flow)
>> 	     then Drop both the packets
>> 	     else if (Qave > maxth)
>> 	          Drop packet
>> 	     else
>> 	       	  Admit packet with proability p (same as RED)
>>=20
>> See also:
>>   Rong Pan, Balaji Prabhakar, Konstantinos Psounis, "CHOKe: a statel=
ess active
>>    queue management scheme for approximating fair bandwidth allocati=
on",=20
>>   Proceeding of INFOCOM'2000, March 2000.
>>=20
>> Help from:
>>      Eric Dumazet <eric.dumazet@gmail.com>
>>      Patrick McHardy <kaber@trash.net>
>>=20
>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>>=20
>> ---
>> 0.11 - incorporates Eric's change to use rxhash
>>=20
>> =20
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Also applied, thanks guys!
