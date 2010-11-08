From: Ben Greear <greearb@candelatech.com>
Subject: Re: OOM when adding ipv6 route:  How to make available more per-cpu
 memory?
Date: Mon, 08 Nov 2010 13:27:41 -0800
Message-ID: <4CD86B4D.6020406@candelatech.com>
References: <4CD43C87.5040403@candelatech.com>	 <1288980361.2882.1070.camel@edumazet-laptop>	 <4CD449A5.5070305@candelatech.com>	 <1288988403.2665.268.camel@edumazet-laptop>	 <1288995103.2665.653.camel@edumazet-laptop>	 <4CD49C2F.3060904@candelatech.com>	 <1289028392.2665.2418.camel@edumazet-laptop>	 <4CD58B9C.2030006@candelatech.com> <1289214131.2820.187.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: NetDev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:32957 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754295Ab0KHV1p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Nov 2010 16:27:45 -0500
In-Reply-To: <1289214131.2820.187.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/08/2010 03:02 AM, Eric Dumazet wrote:
> Le samedi 06 novembre 2010 =C3=A0 10:08 -0700, Ben Greear a =C3=A9cri=
t :
>
>> At least I don't see any percpu dumps in dmesg.  I vaguely remember
>> someone posting some ipv6 address scalability patches some time back=
=2E
>> I think they had to hack on /proc fs as well.  I'll see if I can
>> dig those up.
>>
>>> Make sure udev / hotplug is not the problem, if you create your dev=
ices
>>> very fast.
>>
>> We can create the macvlans w/out problem, though I'm sure that could
>> be sped up.  The problem is when we try to add IPv6 addresses to
>> them.
>
> I see. Did you check /proc/sys/net/ipv6/ tunables ?
>
> For example, I bet you need to make route/max_size a bigger value tha=
n
> default (4096)

I'm having a hard time figuring out how this actually causes something
to fail.

It seems that having max_size too small would cause the garbage collect=
or
logic to happen more often, but I don't see any place it actually
removes or limits entries, and I can't find any other references to
ip6_rt_max_size.

I must just be missing something..so if you have any ideas where to
look, I'd love to hear it!

Thanks,
Ben

--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

