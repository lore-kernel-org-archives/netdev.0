From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Network hangs with 2.6.30.5
Date: Fri, 02 Oct 2009 14:38:30 +0200
Message-ID: <4AC5F446.4090202@gmail.com>
References: <pan.2009.09.03.19.55.37.672875@googlemail.com> <20090907072143.GA5966@ff.dom.local> <20091001.154913.88345178.davem@davemloft.net> <alpine.DEB.2.00.0910021104130.13543@wel-95.cs.helsinki.fi> <alpine.DEB.2.00.0910021520280.13543@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, jarkao2@gmail.com,
	holger.hoffstaette@googlemail.com, Netdev <netdev@vger.kernel.org>,
	Evgeniy Polyakov <zbr@ioremap.net>
To: =?ISO-8859-15?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:56480 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756634AbZJBMig (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2009 08:38:36 -0400
In-Reply-To: <alpine.DEB.2.00.0910021520280.13543@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ilpo J=E4rvinen a =E9crit :
> On Fri, 2 Oct 2009, Ilpo J=E4rvinen wrote:
>=20
>> On Thu, 1 Oct 2009, David Miller wrote:
>>
>>> From: Jarek Poplawski <jarkao2@gmail.com>
>>> Date: Mon, 7 Sep 2009 07:21:43 +0000
>>>
>>>> While Eric is analyzing your data, I guess you could try reverting
>>>> some stuff around this tcp_tw_recycle, and my tcp ignorance would
>>>> point these commits for the beginning:
>>>>
>>>> http://git.kernel.org/?p=3Dlinux/kernel/git/stable/linux-2.6.30.y.=
git;a=3Dcommitdiff;h=3Dfc1ad92dfc4e363a055053746552cdb445ba5c57
>>>> http://git.kernel.org/?p=3Dlinux/kernel/git/stable/linux-2.6.30.y.=
git;a=3Dcommitdiff;h=3Dc887e6d2d9aee56ee7c9f2af4cec3a5efdcc4c72
>>> Ilpo's cleanup (the second commit listed) looks most likely to
>>> be a possibility.
>>>
>>> But I surely cannot find any bugs in it, even after studying it
>>> a few times.
>>>
>>> Ilpo could you audit it one more time for us just in case?
>> Argh, not that one ...the jungle of negations. But I'll try to go it=
=20
>> through once more but I tell you I did go through those negations mu=
ltiple=20
>> times already before submitting it :-).
>>
>>> I also looked through all the TCP commits in 2.6.29 to 2.6.30
>>> and I could not find anything else that might cause stalls with
>>> time-wait recycled connections.
>> What about the more than 64k connections change a9d8f9110d7e953c2f2 =
(or=20
>> its fixes), it might be another possibility? ...It certainly does=20
>> something related to reuse and happens to be in the correct time fra=
me...=20
>> (I've added Evgeniy).

I scratched my head to reproduce the conditions of hang but failed.

I am pretty sure both commits are OK (yours and mine), maybe a brute fo=
rce
git bisection is needed.

