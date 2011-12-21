From: Chris Boot <bootc@bootc.net>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference in ipv6_select_ident
Date: Wed, 21 Dec 2011 21:58:36 +0000
Message-ID: <4EF2568C.6040006@bootc.net>
References: <4EF200BB.7000209@bootc.net>  <1324484956.2301.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <4EF2117F.6000803@bootc.net>  <1324488984.2301.45.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <1324490401.2301.46.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <4EF23BF2.4000601@bootc.net> <1324499332.2621.7.camel@edumazet-laptop> <1324500775.2621.9.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: lkml <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1324500775.2621.9.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 21/12/2011 20:52, Eric Dumazet wrote:
> Le mercredi 21 d=C3=A9cembre 2011 =C3=A0 21:28 +0100, Eric Dumazet a =
=C3=A9crit :
>> Le mercredi 21 d=C3=A9cembre 2011 =C3=A0 20:05 +0000, Chris Boot a =C3=
=A9crit :
>>> On 21/12/2011 18:00, Eric Dumazet wrote:
>>>> Le mercredi 21 d=C3=A9cembre 2011 =C3=A0 18:36 +0100, Eric Dumazet=
 a =C3=A9crit :
>>>>
>>>>> Good point, thats a different problem then, since 3.1 is not supp=
osed to
>>>>> have this bug.
>>>>>
>>>>> It seems rt->rt6i_peer points to invalid memory in your crash.
>>>>>
>>>>> (RBX=3D00000000000001f4)
>>>>>
>>>>> 8b 83 a4 00 00 00       mov    0xa4(%rbx),%eax    p->refcnt
>>>>> 1f4+a4 ->   CR2=3D0000000000000298
>>>>>
>>>> It would help if you can confirm latest linux tree can reproduce t=
he
>>>> bug.
>>> Hi Eric,
>>>
>>> I just built a v3.2-rc6-140-gb9e26df with the same config as the De=
bian
>>> 3.1.0 kernel. I can reproduce the bug just as easily with this kern=
el as
>>> with the Debian kernel. Unfortunately I wasn't able to get an entir=
e
>>> trace, for some reason it didn't appear to be printed to the serial=
 port
>>> and hung after the (long) list of loaded kernel modules. The crash
>>> happens at the same offset:
>>>
>> Thanks !
>>
>> Oh well, br_netfilter fake_rtable strikes again.
>>
>> I'll cook a patch in a couple of minutes...
>>
> Could you try following patch ?
>
> [snip]

Eric,

It looks good! The rsync that caused the crash real quick hasn't done i=
t=20
at all with the patch applied. I'll keep testing it of course, but I=20
think that's done it.

Many thanks indeed!

Chris

--=20
Chris Boot
bootc@bootc.net
