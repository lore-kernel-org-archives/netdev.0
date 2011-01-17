From: Arthur Marsh <arthur.marsh@internode.on.net>
Subject: Re: inbound connection problems when "netlink: test for all flags
 of the NLM_F_DUMP composite" commit applied
Date: Mon, 17 Jan 2011 11:33:10 +1030
Message-ID: <4D33954E.7090408@internode.on.net>
References: <54347.1295168081@internode.on.net> <1295169670.3977.36.camel@edumazet-laptop> <alpine.LNX.2.01.1101161144350.8081@obet.zrqbmnf.qr> <4D32E3BA.5040008@internode.on.net> <4D336050.9030602@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jan Engelhardt <jengelh@medozas.de>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bld-mail13.adl6.internode.on.net ([150.101.137.98]:50307 "EHLO
	mail.internode.on.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751709Ab1AQBDS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Jan 2011 20:03:18 -0500
In-Reply-To: <4D336050.9030602@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Pablo Neira Ayuso wrote, on 17/01/11 07:47:
> On 16/01/11 13:25, Arthur Marsh wrote:
>> Jan Engelhardt wrote, on 16/01/11 21:20:
>>>
>>> Le dimanche 16 janvier 2011 =C3=A0 19:24 +1030, Arthur Marsh a =C3=A9=
crit :
>>>>
>>>>> With kernels up to and including 2.6.37-git7, inbound telnetd-ssl
>>>>> connections worked fine. With kernel 2.6.37-git9 and later inboun=
d
>>>>> telnetd-ssl connections failed, and on machine shut-down, there
>>>>> were warning messages about daemons not return status.
>>>
>>> Which daemons are these? For reference, what distro do you happen
>>> to use?
>>
>> avahi-daemon (which gave multiple warning messages, hence I thought =
it
>> may have been multiple packages)
>>
>> I'm running Debian unstable with kernel.org kernels.
>>
>>>
>>>>> commit 0ab03c2b1478f2438d2c80204f7fef65b1bca9cf
>>>>>       netlink: test for all flags of the NLM_F_DUMP composite
>>>
>>> Each of the hunks in this commit is independent of another.
>>> Would you mind bisecting these too?
>>
>> Recompiling with the only the first patch (attached) resulted in a
>> repeat of the problem.
>>
>> I've removed one person from the cc: list as they did not want to
>> receive email about this even though they signed off the commit.
>
> Please, pass this patch to the avahi-daemon developers. They use an
> invalid netlink flag combination for dump operations.
>
> This patch has spotted a problem that they have to fix indeed.
>

I've forwarded this on as a Debian bug:

http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=3D610281

Regards,

Arthur.
