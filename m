From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Sysctl interface to UNIX_INFLIGHT_TRIGGER_GC v.3
Date: Fri, 10 Dec 2010 14:04:33 +0100
Message-ID: <1291986273.3580.16.camel@edumazet-laptop>
References: <4D011136.8030404@pavlinux.ru> <4D01A26C.8060608@cn.fujitsu.com>
	 <4D0221A2.4010602@pavlinux.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Shan Wei <shanwei@cn.fujitsu.com>, netdev@vger.kernel.org
To: pavel@pavlinux.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:62192 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756256Ab0LJNEh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 08:04:37 -0500
Received: by wwa36 with SMTP id 36so3686026wwa.1
        for <netdev@vger.kernel.org>; Fri, 10 Dec 2010 05:04:36 -0800 (PST)
In-Reply-To: <4D0221A2.4010602@pavlinux.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 10 d=C3=A9cembre 2010 =C3=A0 15:48 +0300, Pavel Vasilyev a =
=C3=A9crit :
> On 10.12.2010 06:45, Shan Wei wrote:
> > Pavel Vasilyev wrote, at 12/10/2010 01:26 AM:
> >> Sysctl interface to UNIX_INFLIGHT_TRIGGER_GC.
> >> IMHO convenient for testing.
> >>
> >> +inflight_trigger_gc - INTEGER
> >> +	The maximal number of inflight sockets for force garbage collect=
=2E
> >> +
> >> +	Default: 16000
> >=20
> > 1) For lower payload and enough memory, it's not necessary to force=
 garbage collection.
> > So set it to 0, disable gc.
>=20
>=20
> May be, set default to 2000, and zero to disable
>=20

zero to disable ?

Maybe you missed commit 9915672d41273f5b77 intent.

If you have no limit (like old kernels), you can freeze your machine,
even if it has terabytes of ram, running a single program, even as a no=
n
root user.

When we discussed about the fix, we said a limit was needed, obviously.

Now you'll have to prove we need to make it a sysctl (yet
another /proc/sys/net parameter, yet another documentation to add...)

Even changing default from 16000 to 2000 must be for a valid reason (a
real use case)



