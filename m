From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: kernel hangs when removing a dummy netdev with an attached macvlan
Date: Tue, 24 Aug 2010 21:14:46 +0200
Message-ID: <4C741A26.5090200@free.fr>
References: <4C73F419.2050204@free.fr> <1282669312.2477.262.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.17.165]:43183 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751805Ab0HXTO6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Aug 2010 15:14:58 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate5.de.ibm.com (8.13.1/8.13.1) with ESMTP id o7OJEvPC024886
	for <netdev@vger.kernel.org>; Tue, 24 Aug 2010 19:14:57 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o7OJEvoB4128946
	for <netdev@vger.kernel.org>; Tue, 24 Aug 2010 21:14:57 +0200
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id o7OJEu10016752
	for <netdev@vger.kernel.org>; Tue, 24 Aug 2010 21:14:56 +0200
In-Reply-To: <1282669312.2477.262.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/24/2010 07:01 PM, Eric Dumazet wrote:
> Le mardi 24 ao=C3=BBt 2010 =C3=A0 18:32 +0200, Daniel Lezcano a =C3=A9=
crit :
>   =20
>> Hi all,
>>
>> I noticed the kernel hangs when we create a dummy interface, assign =
a
>> macvlan on it and then delete the dummy interface.
>>
>> How to reproduce:
>>
>>    ip link add dummy0 type dummy
>>    ip link add mc0 link dummy0 type macvlan
>>    ip link del dummy0
>>
>>     =20
> Strange, I could not reproduce it with linux-2.6 current tree
>   =20

Right, I was not up to date. The bug does no longer appear with the=20
net-next-2.6 git head.

Sorry for the noise.

   -- Daniel
