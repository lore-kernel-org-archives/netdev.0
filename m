From: Piotr Hosowicz <piotr@hosowicz.com>
Subject: Re: [2.6.34-rc5-git6] EIP: is at inet6_csk_bind_conflict + 06xe/0xb7
 	[ipv6]
Date: Sun, 25 Apr 2010 18:36:44 +0200
Message-ID: <4BD46F9C.5060500@example.com>
References: <l2z2d0a357f1004250811w6da355ebp95d1730473026c22@mail.gmail.com>	 <4BD45E68.4080900@example.com> <g2z2d0a357f1004250931pf5880c60l32fd0643e0f14bde@mail.gmail.com>
Reply-To: piotr@hosowicz.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sedat Dilek <sedat.dilek@googlemail.com>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Jiri Olsa <jolsa@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jongman Heo <jongman.heo@gmail.com>
To: sedat.dilek@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 26.mail-out.ovh.net ([91.121.27.225]:56081 "HELO
	26.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752424Ab0DYQgt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Apr 2010 12:36:49 -0400
In-Reply-To: <g2z2d0a357f1004250931pf5880c60l32fd0643e0f14bde@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25.04.2010 18:31, Sedat Dilek wrote:
> [ CCing netdev ML ]
>
> Confirmed: The revert-patch [1] fixes the problem here.

I confirm, I've built a git6 kernel and it works fine.

> See also "Bug 15847 -  crash in inet6_csk_bind_conflict" [2].
>
> Feel free to add a... Tested-by: Sedat Dilek<sedat.dilek@gmail.com>

I added created and tested phrase in my archive. ;-) Thank you a lot. I=
=20
hope there will be no this error in git7.

Regards,

Piotr Hosowicz

> - Sedat -
>
> [1] https://patchwork.kernel.org/patch/94959/
> [2] https://bugzilla.kernel.org/show_bug.cgi?id=3D15847
>
> 2010/4/25 Piotr Hosowicz<piotr@hosowicz.com>:
>> On 25.04.2010 17:11, Sedat Dilek wrote:
>>>
>>> [ Please CC - I am not subscribed to LKML ]
>>>
>>> [QUOTE]
>>>
>>> On 25.04.2010 16:26, Jongman Heo wrote:
>>>
>>>> I also hit this bug today.
>>>
>>> I also hit similar bug, maybe it is the same.
>>>
>>>> Doing git bisect, first bad commit was
>>>>
>>>>    commit fda48a0d7a8412cedacda46a9c0bf8ef9cd13559
>>>>    tcp: bind() fix when many ports are bound
>>>>
>>>> Reverting above commit fixes the problem.
>>>
>>> How to do it? Would you please publish a reverting patch?
>>>
>>> Regards,
>>>
>>> Piotr Hosowicz
>>>
>>> [/QUOTE]
>>>
>>> Hi,
>>>
>>> did forget to mention 2.6.34-rc5-git5 was OK.
>>>
>>> Revering this commit did not help:
>>>
>>> commit f4f914b58019f0e50d521bbbadfaee260d766f95
>>> net: ipv6 bind to device issue
>>>
>>> After looking into net-2.6 GIT repository, "tcp: bind() fix when ma=
ny
>>> ports are bound" could cause indeed the problems here, too.
>>> Building now....
>>>
>>> Regards,
>>> - Sedat -
>>>
>>> P.S.: Attached 0001-Revert-tcp-bind-fix-when-many-ports-are-bound.p=
atch
>>
>> Thanks a lot. Applied and building now.
>>
>> Regards,
>>
>> Piotr Hosowicz
>>
>> --
>> Z cyklu "Uroki demokracji", czyli pytania i odpowiedzi w teledurniej=
ach:
>> - W kt=F3rym kraju znajduje si=EA Mount Everest?
>> - Hm, to nie Szkocja, prawda?
>> NP: Mark Knopfler - Cleaning My Gun
>> NB: 2.6.34-rc5-git5
>>
>


--=20
Grupa marze=F1 w eliminacjach M=A6 :
Zimbabwe, Alaska, Grenlandia, Antarktyda i Zair.
NP: Chickenfoot - Oh Yeah
NB: 2.6.34-rc5-git6
