From: Luciano Coelho <luciano.coelho@nokia.com>
Subject: Re: neigh_periodic_timer expires too often
Date: Wed, 05 Aug 2009 10:48:30 +0300
Message-ID: <4A79394E.1030001@nokia.com>
References: <4A717985.7060909@nokia.com> <4A719CDB.3060004@gmail.com> <4A71AF1D.9020000@nokia.com> <4A72E204.3050704@nokia.com> <4A72E8A1.2070705@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kristo Tero (Nokia-D/Tampere)" <Tero.Kristo@nokia.com>
To: ext Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:16826 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933355AbZHEHsl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2009 03:48:41 -0400
In-Reply-To: <4A72E8A1.2070705@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ext Eric Dumazet wrote:
> Luciano Coelho a =E9crit :
>  =20
>> Coelho Luciano (Nokia-D/Helsinki) wrote:
>>    =20
>>> ext Eric Dumazet wrote:
>>> =20
>>>      =20
>>>> So please test it and tell me/us you like it :)
>>>>      =20
>>>>        =20
>>> I applied your patch on top of the 2.6.28 I'm using and will start
>>> testing it now.  I can also try to test it on top of 2.6.31-rc4 plu=
s
>>> wireless-testing stuff, if needed.
>>>
>>> I'll tell you that I liked your patch in a moment (I actually alrea=
dy
>>> liked it, but I'll wait until I know it works before I tell you ;)
>>>  =20
>>>      =20
>> Just a small update.  We have run some very basic tests with 2.6.28.=
=20
>> The patch seems to work fine and we don't see excessive wake-ups fro=
m
>> neigh anymore (thanks Tero for helping with the tests).  We will sti=
ll
>> run one of our full release test rounds in order to make sure that t=
here
>> are no regressions.  I'll let you know when we have some more result=
s.
>>
>>    =20
>
> Thanks for the update, I am running this patch on net-next-2.6 with n=
o problem.
>  =20

We have now run our release round tests and everything is working fine.=
 =20
I'll report back if we find any issues with this change in the future=20
(which I really don't expect to happen ;).

Thank you very much for fixing this.

--=20
Cheers,
Luca.

