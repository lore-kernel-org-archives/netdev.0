From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Sysctl interface to UNIX_INFLIGHT_TRIGGER_GC v.3
Date: Fri, 10 Dec 2010 12:56:05 -0800 (PST)
Message-ID: <20101210.125605.258094157.davem@davemloft.net>
References: <4D01A26C.8060608@cn.fujitsu.com>
	<4D0221A2.4010602@pavlinux.ru>
	<1291986273.3580.16.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: pavel@pavlinux.ru, shanwei@cn.fujitsu.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40041
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757128Ab0LJUzi convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Dec 2010 15:55:38 -0500
In-Reply-To: <1291986273.3580.16.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 10 Dec 2010 14:04:33 +0100

> Le vendredi 10 d=E9cembre 2010 =E0 15:48 +0300, Pavel Vasilyev a =E9c=
rit :
>> On 10.12.2010 06:45, Shan Wei wrote:
>> > Pavel Vasilyev wrote, at 12/10/2010 01:26 AM:
>> >> Sysctl interface to UNIX_INFLIGHT_TRIGGER_GC.
>> >> IMHO convenient for testing.
>> >>
>> >> +inflight_trigger_gc - INTEGER
>> >> +	The maximal number of inflight sockets for force garbage collec=
t.
>> >> +
>> >> +	Default: 16000
>> >=20
>> > 1) For lower payload and enough memory, it's not necessary to forc=
e garbage collection.
>> > So set it to 0, disable gc.
>>=20
>>=20
>> May be, set default to 2000, and zero to disable
>>=20
>=20
> zero to disable ?
>=20
> Maybe you missed commit 9915672d41273f5b77 intent.
>=20
> If you have no limit (like old kernels), you can freeze your machine,
> even if it has terabytes of ram, running a single program, even as a =
non
> root user.
>=20
> When we discussed about the fix, we said a limit was needed, obviousl=
y.
>=20
> Now you'll have to prove we need to make it a sysctl (yet
> another /proc/sys/net parameter, yet another documentation to add...)
>=20
> Even changing default from 16000 to 2000 must be for a valid reason (=
a
> real use case)

I don't want to add this sysctl.  Exactly because there is no reason
to believe that the current value could even need to be changed by
anyone.

Once a demonstratable need can be proven and shown beyond a shadow
of a doubt, we can consider adding the sysctl.

We have too many damn sysctls as-is.
