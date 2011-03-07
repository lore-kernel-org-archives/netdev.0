From: =?UTF-8?Q?Ernst_Sj=C3=B6strand?= <ernstp@gmail.com>
Subject: Re: [Bugme-new] [Bug 30462] New: High cpu usage when someone sends
 many ipv6 udp packages
Date: Mon, 7 Mar 2011 20:54:21 +0100
Message-ID: <AANLkTimBqrZNSumjJN3riNk=+6Agtxn7KzujwkWZ35au@mail.gmail.com>
References: <bug-30462-10286@https.bugzilla.kernel.org/>
	<20110304171506.0e27cde1.akpm@linux-foundation.org>
	<20110304.172157.48483962.davem@davemloft.net>
	<AANLkTim9FKD7RRi02b+5=gQ85jNybqVtoT_ydW0imNev@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:41975 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755997Ab1CGTyW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2011 14:54:22 -0500
Received: by vxi39 with SMTP id 39so4029423vxi.19
        for <netdev@vger.kernel.org>; Mon, 07 Mar 2011 11:54:21 -0800 (PST)
In-Reply-To: <AANLkTim9FKD7RRi02b+5=gQ85jNybqVtoT_ydW0imNev@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

seems like reverting "ipv6: Always clone offlink routes." fixes the iss=
ue.

Regards
//Ernst

2011/3/5 Ernst Sj=C3=B6strand <ernstp@gmail.com>:
> I've only used precompiled kernels so far so I don't have stuff set u=
p to
> compile kernels right now,
> probably won't have time to do that this weekend. Not tonight in GMT+=
1
> anyway!
>
> Regards
> //Ernst
>
> On Sat, Mar 5, 2011 at 02:21, David Miller <davem@davemloft.net> wrot=
e:
>>
>> From: Andrew Morton <akpm@linux-foundation.org>
>> Date: Fri, 4 Mar 2011 17:15:06 -0800
>>
>> >> The following ipv6 related changes were introduced between -rc2 a=
nd
>> >> -rc3 that I
>> >> can see. The "Revert 'administrative down' address handling chang=
es."
>> >> looked
>> >> big...
>> >> =C2=A0 =C2=A0 =C2=A0 ipv6: Always clone offlink routes.
>> >> =C2=A0 =C2=A0 =C2=A0 ipv6: Revert 'administrative down' address h=
andling changes.
>>
>> Can we narrow it down to which of those two changes introduced the
>> regression?
>>
>> We have another issue, still open, which is caused by the first
>> change, so maybe try reverting that one first.
>>
>> Thanks.
>
>
