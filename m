From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Security] [SECURITY] Fix leaking of kernel heap addresses via
 /proc
Date: Mon, 08 Nov 2010 11:14:18 +0100
Message-ID: <1289211258.2820.176.camel@edumazet-laptop>
References: <201011072248.oA7MmjKg025857@cmf.nrl.navy.mil>
	 <1289172456.3090.184.camel@Dan> <20101107235610.GE17592@basil.fritz.box>
	 <20101107.180108.71121019.davem@davemloft.net>
	 <1289201612.2478.371.camel@edumazet-laptop>
	 <20101108094358.GA22069@basil.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, drosenberg@vsecurity.com,
	chas3@users.sourceforge.net, tytso@mit.edu,
	torvalds@linux-foundation.org, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, remi.denis-courmont@nokia.com,
	netdev@vger.kernel.org, security@kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:34327 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751633Ab0KHKOX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Nov 2010 05:14:23 -0500
Received: by fxm16 with SMTP id 16so3850657fxm.19
        for <netdev@vger.kernel.org>; Mon, 08 Nov 2010 02:14:22 -0800 (PST)
In-Reply-To: <20101108094358.GA22069@basil.fritz.box>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 08 novembre 2010 =C3=A0 10:43 +0100, Andi Kleen a =C3=A9crit :
> > When a printk() happens right before a BUG(), how are we going to c=
heck
> > the dumped registers are possibly close the socket involved, if we =
dont
> > have access to the machine, and only the crashlog ?
>=20
> Is that really something you do regularly? It seems highly obscure
> to me.

Yes, very regularly, I can find bugs thanks to every bit of information
found in kernel logs, including code around the fault.

If people now say : "I have a kernel bug, but am not able to provide yo=
u
a kernel stack trace and previous printk() messages because of security=
=2E
You cannot have an access to this machine, and the bug happens once in =
a
while. Kernel version is also hidden. Please help me."

Oh well, thats a challenge, maybe use this cristal ball I have somewher=
e
in the attic ;)



