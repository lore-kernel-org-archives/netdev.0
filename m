From: Ben Greear <greearb@candelatech.com>
Subject: Re: OOM when adding ipv6 route:  How to make available more per-cpu
 memory?
Date: Sat, 06 Nov 2010 10:08:44 -0700
Message-ID: <4CD58B9C.2030006@candelatech.com>
References: <4CD43C87.5040403@candelatech.com>	 <1288980361.2882.1070.camel@edumazet-laptop>	 <4CD449A5.5070305@candelatech.com>	 <1288988403.2665.268.camel@edumazet-laptop>	 <1288995103.2665.653.camel@edumazet-laptop>	 <4CD49C2F.3060904@candelatech.com> <1289028392.2665.2418.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: NetDev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Tejun Heo <tj@kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1289028392.2665.2418.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/06/2010 12:26 AM, Eric Dumazet wrote:
> Le vendredi 05 novembre 2010 =C3=A0 17:07 -0700, Ben Greear a =C3=A9c=
rit :
>
>> We just tried creating 1000 macvlans with IPv6 addrs on a 64-bit mac=
hine
>> with 12GB RAM.  Only around 520 interfaces properly set their IPs, a=
nd
>> again there are errors about of-of-memory from 'ip', but no obvious
>> splats in dmesg.
>>
>> 'top' shows 10G or so free.
>>
>> It will take some time to figure out what exactly is returning
>> the ENOMEM....
>
> At least, nothing to do with percpu stuff ?

At least I don't see any percpu dumps in dmesg.  I vaguely remember
someone posting some ipv6 address scalability patches some time back.
I think they had to hack on /proc fs as well.  I'll see if I can
dig those up.

> Make sure udev / hotplug is not the problem, if you create your devic=
es
> very fast.

We can create the macvlans w/out problem, though I'm sure that could
be sped up.  The problem is when we try to add IPv6 addresses to
them.

Thanks,
Ben


--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
