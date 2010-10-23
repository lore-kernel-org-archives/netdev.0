From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: kernel panic in fib_rules_lookup [2.6.27.7 vendor-patched]
Date: Sat, 23 Oct 2010 18:35:45 +0200
Message-ID: <1287851745.2658.364.camel@edumazet-laptop>
References: <loom.20101012T185411-307@post.gmane.org>
	 <1286905245.2703.3.camel@edumazet-laptop>  <4CBF2A3F.2070108@cox.net>
	 <1287612353.2545.11.camel@edumazet-laptop>  <4CC1F47C.9020104@cox.net>
	 <1287805487.2658.5.camel@edumazet-laptop>
	 <1287846669.2658.247.camel@edumazet-laptop>  <4CC30055.5040509@cox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Joe Buehler <aspam@cox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:55317 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757366Ab0JWQfx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Oct 2010 12:35:53 -0400
Received: by wyf28 with SMTP id 28so1946834wyf.19
        for <netdev@vger.kernel.org>; Sat, 23 Oct 2010 09:35:52 -0700 (PDT)
In-Reply-To: <4CC30055.5040509@cox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 23 octobre 2010 =C3=A0 11:33 -0400, Joe Buehler a =C3=A9crit =
:

> It is always possible that there is some issue with the Octeon memory
> barrier stuff, but I would think that the system would be much more
> unstable than it is -- we're really beating on a dual CPU LINUX insta=
nce
> that has Java and C++ apps running and also doing some network I/O.
>=20
> My strategy at this point is logging events to memory and dumping the
> log to the console at the time of the panic.  I might be able to figu=
re
> out the sequence of events causing the crash.
>=20
> The load test that causes the panic is using several dozen TAP
> interfaces, ifconfig'd up/down every 10 seconds or so, with
> source-routes, DNAT and SNAT being set up and taken down also.

With a normal workload, on a dual cpu machine, a missing memory barrier
can stay un-noticed for quite a long time. The race window is so small
that probability for the bug might be 0.0000001 % or something like
that :(

You could try to run a test dual threaded program to reproduce the
problem in user land, faster...



