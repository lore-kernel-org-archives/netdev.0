From: Yann Dupont <Yann.Dupont@univ-nantes.fr>
Subject: Re: kernel 2.6.37 : oops in cleanup_once
Date: Wed, 02 Feb 2011 14:08:53 +0100
Message-ID: <4D495765.4090806@univ-nantes.fr>
References: <4D491B8D.1000107@univ-nantes.fr>	 <1296643972.20445.9.camel@edumazet-laptop> <1296645887.20445.11.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1296645887.20445.11.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 02/02/2011 12:24, Eric Dumazet a =C3=A9crit :
> Le mercredi 02 f=C3=A9vrier 2011 =C3=A0 11:52 +0100, Eric Dumazet a =C3=
=A9crit :
>> Le mercredi 02 f=C3=A9vrier 2011 =C3=A0 09:53 +0100, Yann Dupont a =C3=
=A9crit :
>>> Hello.
>>> We recently upgraded one machine with vanilla 2.6.37, and experienc=
ed 2
>>> kernel oops since. Each oops is after ~1 week of uptime.
>>> The last oops was last night but we didn't had any trace.
> oops, 2.6.37 "only"
>
>> Yes this is a known problem.
>>
>> Please try commit 3408404a4c2a4eead9d73b0bbbfe3f225b65f492
>> (inetpeer: Use correct AVL tree base pointer in inet_getpeer())
>>
>> http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=
=3Dcommitdiff;h=3D3408404a4c2a4eead9d73b0bbbfe3f225b65f492
>>
>> I believe David will send it to stable team shortly, if not already
>> done :)
> Please ignore, this patch was for linux-2.6 tree, 2.6.37 was not
> affected by the problem.
>
> So its another problem... Is there anything particular you do on this
> machine ?
>
>
>
>
Nothing really special there, we run a lot (20) of KVM guest (mainly=20
linux firewalls for lots of differents vlan), so we have a lot of=20
bridges vlan & tun/tap.
Oh, and CONFIG_BRIDGE_IGMP_SNOOPING is set to n (because of  the other=20
bug already sent to netdev - more to come on next mail)

Hard to say if this BUG is new in 2.6.37. This host was running fine=20
with 2.6.34.2 since August 2010.
Bisecting will be hard due to the time to trigger the bug (and the fact=
=20
that this machine is a production machine)

Anyway, I can test with a specific kernel version if you suspect someth=
ing.

Regards,


--=20
Yann Dupont - Service IRTS, DSI Universit=C3=A9 de Nantes
Tel : 02.53.48.49.20 - Mail/Jabber : Yann.Dupont@univ-nantes.fr
