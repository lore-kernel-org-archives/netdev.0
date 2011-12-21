From: Chris Boot <bootc@bootc.net>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference in ipv6_select_ident
Date: Wed, 21 Dec 2011 17:03:59 +0000
Message-ID: <4EF2117F.6000803@bootc.net>
References: <4EF200BB.7000209@bootc.net> <1324484956.2301.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: lkml <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1324484956.2301.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 21/12/2011 16:29, Eric Dumazet wrote:
> Le mercredi 21 d=C3=A9cembre 2011 =C3=A0 15:52 +0000, Chris Boot a =C3=
=A9crit :
>> Hi folks,
>>
>> I'm working on getting a 2-node VM cluster up and running, with DRBD=
 and
>> Corosync/Pacemaker, running KVM VMs.
>>
>> I can trigger a kernel panic in either _host_ system when running an
>> rsync on a _guest_ VM. The rsync is simply SSH over IPv6 from a remo=
te
>> mail store (containing maildirs) to a local filesystem. I'm basicall=
y
>> working on migrating a physical IMAP server to one inside a VM.
>>
>> After a few seconds of fairly heavy IPv6 traffic, I get the panic be=
low.
>> You'll notice the panic refers to vhost_net, but I tried without tha=
t
>> and the kernel panics at exactly the same call point.
>>
>> Panic:
>>
>> [snip]
>>
>> Any insight will be gratefully received.
>>
>> Thanks,
>> Chris
>>
> Is it a debian kernel ?
>
> You need : https://lkml.org/lkml/2011/10/11/291

Eric,

Aha, that sounds like exactly the culprit, thanks. However I can't find=
=20
any reference to it in the 3.1 to 3.1.5 changelogs. Is it fixed in any=20
of those kernels or would I have to attempt to forward-port the fix mys=
elf?

Cheers,
Chris

--=20
Chris Boot
bootc@bootc.net
