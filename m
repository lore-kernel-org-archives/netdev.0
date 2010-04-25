From: Sedat Dilek <sedat.dilek@googlemail.com>
Subject: Re: [2.6.34-rc5-git6] EIP: is at inet6_csk_bind_conflict + 06xe/0xb7
	[ipv6]
Date: Sun, 25 Apr 2010 18:31:31 +0200
Message-ID: <g2z2d0a357f1004250931pf5880c60l32fd0643e0f14bde@mail.gmail.com>
References: <l2z2d0a357f1004250811w6da355ebp95d1730473026c22@mail.gmail.com>
	 <4BD45E68.4080900@example.com>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Jiri Olsa <jolsa@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jongman Heo <jongman.heo@gmail.com>
To: piotr@hosowicz.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:48973 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752589Ab0DYQbd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Apr 2010 12:31:33 -0400
In-Reply-To: <4BD45E68.4080900@example.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[ CCing netdev ML ]

Confirmed: The revert-patch [1] fixes the problem here.

See also "Bug 15847 -  crash in inet6_csk_bind_conflict" [2].

=46eel free to add a... Tested-by: Sedat Dilek <sedat.dilek@gmail.com>

- Sedat -

[1] https://patchwork.kernel.org/patch/94959/
[2] https://bugzilla.kernel.org/show_bug.cgi?id=3D15847

2010/4/25 Piotr Hosowicz <piotr@hosowicz.com>:
> On 25.04.2010 17:11, Sedat Dilek wrote:
>>
>> [ Please CC - I am not subscribed to LKML ]
>>
>> [QUOTE]
>>
>> On 25.04.2010 16:26, Jongman Heo wrote:
>>
>>> I also hit this bug today.
>>
>> I also hit similar bug, maybe it is the same.
>>
>>> Doing git bisect, first bad commit was
>>>
>>> =C2=A0 commit fda48a0d7a8412cedacda46a9c0bf8ef9cd13559
>>> =C2=A0 tcp: bind() fix when many ports are bound
>>>
>>> Reverting above commit fixes the problem.
>>
>> How to do it? Would you please publish a reverting patch?
>>
>> Regards,
>>
>> Piotr Hosowicz
>>
>> [/QUOTE]
>>
>> Hi,
>>
>> did forget to mention 2.6.34-rc5-git5 was OK.
>>
>> Revering this commit did not help:
>>
>> commit f4f914b58019f0e50d521bbbadfaee260d766f95
>> net: ipv6 bind to device issue
>>
>> After looking into net-2.6 GIT repository, "tcp: bind() fix when man=
y
>> ports are bound" could cause indeed the problems here, too.
>> Building now....
>>
>> Regards,
>> - Sedat -
>>
>> P.S.: Attached 0001-Revert-tcp-bind-fix-when-many-ports-are-bound.pa=
tch
>
> Thanks a lot. Applied and building now.
>
> Regards,
>
> Piotr Hosowicz
>
> --
> Z cyklu "Uroki demokracji", czyli pytania i odpowiedzi w teledurnieja=
ch:
> - W kt=C3=B3rym kraju znajduje si=C4=99 Mount Everest?
> - Hm, to nie Szkocja, prawda?
> NP: Mark Knopfler - Cleaning My Gun
> NB: 2.6.34-rc5-git5
>
