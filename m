From: Ben Greear <greearb@candelatech.com>
Subject: Re: [net-next-2.6 PATCH] net: fast consecutive name allocation
Date: Sat, 14 Nov 2009 08:16:46 -0800
Message-ID: <4AFED7EE.2000209@candelatech.com>
References: <200911130701.14847.opurdila@ixiacom.com>	<4AFCF8D3.6090905@gmail.com> <20091112222608.79d90e9e@nehalam>	<200911131151.31677.opurdila@ixiacom.com>	<20091113142939.35879efe@s6510> <20091113224043.GP19478@kvack.org>	<20091113144937.23693bb4@nehalam> <m3r5s1bn3f.fsf@ursa.amorsen.dk> <4AFE5A6C.2030301@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Benny Amorsen <benny+usenet@amorsen.dk>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Benjamin LaHaise <bcrl@lhnet.ca>,
	Octavian Purdila <opurdila@ixiacom.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:49850 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751788AbZKNQQx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Nov 2009 11:16:53 -0500
In-Reply-To: <4AFE5A6C.2030301@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Benny Amorsen a =E9crit :
>  =20
>> Stephen Hemminger <shemminger@vyatta.com> writes:
>>
>>    =20
>>> Then maybe network devices aren't the right layering model. At some
>>> point the paradigm has to be re-examined.
>>>      =20
>> I'm not quite sure where this becomes a problem. We have 1185 networ=
k
>> interfaces (VLAN's) on one box. Boot time is a problem, but other th=
an
>> that it works ok. If something like this would help speed up booting=
,
>> that would be very nice.
>>
>>    =20
>
> It would be very nice if you tell us why booting is very long,
> ie what is done and how much time it takes.
>
> It's clear that ~1000 vlans is quite reasonable :)
>  =20
At least sometimes, hotplug can degrade into a nasty case where it runs=
=20
'ifconfig -a' for each
interface created.   (This was F11 if I recall correctly).

If you configure hotplug to ignore vlans, it might help your boot time.

Thanks,
Ben

>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>  =20


--=20
Ben Greear <greearb@candelatech.com>=20
Candela Technologies Inc  http://www.candelatech.com


