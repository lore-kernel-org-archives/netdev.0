From: Lars Ellenberg <lars.ellenberg@linbit.com>
Subject: Re: Bug report: broadcast address as incomplete entry in arp table, effectively a blackhole; reproducer included
Date: Thu, 12 Mar 2015 08:27:20 +0100
Message-ID: <F2F490FA-3AED-436B-BB9E-818353BCEA9B@linbit.com>
References: <20140924161847.GG7118@soda.linbit> <20141119143958.GP307@soda.linbit> <5500AC15.2020200@emagii.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Ulf Samuelsson <netdev@emagii.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra13.linbit.com ([212.69.166.240]:57244 "EHLO
	zimbra13.linbit.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752661AbbCLHga convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 03:36:30 -0400
In-Reply-To: <5500AC15.2020200@emagii.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 11. M=C3=A4rz 2015 21:56:53 MEZ, schrieb Ulf Samuelsson <netdev@emag=
ii.com>:
>Den 2014-11-19 15:39, Lars Ellenberg skrev:
>> Ping ...
>> Any ideas?
>>
>> 	Lars
>Did you ever solve this problem?


There are the stated workarounds.
No solution.
In fact this is the first reaction I had at all.

>Have been working on a similar problem.
>
>Are you sure that the entry is never removed?

Not sure, never is a long time to cover. Not within hours, though.
And not deletable "by hand".
My guess it's that it is in some part of the table that is not walked a=
nymore, because the system"knows" that this entry cannot possibly exist=
, so why even bother to look :-/

>Once you lose the entry, it is normally garbage collected,
>and this takes a looong time (minutes).
>
>Try leaving it alone for an hour once the problem occurs,
>and check if the garbage collector has not taken the entry out.

You realize that I can reproduce at will, I can provoke the problem.


>The ARP state machine has, as far as I know, no way
>to put an entry into INCOMPLETE once it has reached REACHABLE.
>
>Once in REACHABLE it will move between the following valid states:

It never was reachable.
It either is the broadcast address, which won't be ARP resolved obvious=
ly. Or it is unreachable -- nothing has the supposedly broadcast addres=
s assigned...

Thanks,
    Lars
