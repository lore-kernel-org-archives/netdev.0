From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next-2.6 PATCH] net: fast consecutive name allocation
Date: Sat, 14 Nov 2009 08:21:16 +0100
Message-ID: <4AFE5A6C.2030301@gmail.com>
References: <200911130701.14847.opurdila@ixiacom.com>	<4AFCF8D3.6090905@gmail.com> <20091112222608.79d90e9e@nehalam>	<200911131151.31677.opurdila@ixiacom.com>	<20091113142939.35879efe@s6510> <20091113224043.GP19478@kvack.org>	<20091113144937.23693bb4@nehalam> <m3r5s1bn3f.fsf@ursa.amorsen.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Benjamin LaHaise <bcrl@lhnet.ca>,
	Octavian Purdila <opurdila@ixiacom.com>, netdev@vger.kernel.org
To: Benny Amorsen <benny+usenet@amorsen.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:53342 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752758AbZKNHVU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Nov 2009 02:21:20 -0500
In-Reply-To: <m3r5s1bn3f.fsf@ursa.amorsen.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Benny Amorsen a =E9crit :
> Stephen Hemminger <shemminger@vyatta.com> writes:
>=20
>> Then maybe network devices aren't the right layering model. At some
>> point the paradigm has to be re-examined.
>=20
> I'm not quite sure where this becomes a problem. We have 1185 network
> interfaces (VLAN's) on one box. Boot time is a problem, but other tha=
n
> that it works ok. If something like this would help speed up booting,
> that would be very nice.
>=20

It would be very nice if you tell us why booting is very long,
ie what is done and how much time it takes.

It's clear that ~1000 vlans is quite reasonable :)


