From: =?ISO-8859-1?Q?D=E2niel?= Fraga <fragabr@gmail.com>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility
 workaround (fwd)
Date: Thu, 2 Oct 2008 18:39:17 -0300
Message-ID: <48e53f8a.070fc00a.3f20.ffffda0e@mx.google.com>
References: <Pine.LNX.4.64.0810011546371.1034@wrl-59.cs.helsinki.fi>
	<48e3a4e5.0d1d640a.4cd3.06e9@mx.google.com>
	<alpine.LFD.1.10.0810012140360.5549@apollo.tec.linutronix.de>
	<48e3e835.0906c00a.2cd1.2fd1@mx.google.com>
	<alpine.LFD.1.10.0810021142370.5549@apollo.tec.linutronix.de>
	<48e4adb8.0807c00a.62b8.ffff87d6@mx.google.com>
	<alpine.LFD.1.10.0810021407400.5549@apollo.tec.linutronix.de>
	<48e4d63a.060ec00a.6a4e.ffff95bf@mx.google.com>
	<alpine.LFD.1.10.0810022113540.5549@apollo.tec.linutronix.de>
	<Pine.LNX.4.64.0810022251400.22964@wrl-59.cs.helsinki.fi>
	<48e5364d.0603c00a.6e25.fffff993@mx.google.com>
	<Pine.LNX.4.64.0810030008280.22964@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Thomas Gleixner <tglx@linutronix.de>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: "Ilpo =?ISO-8859-1?Q?J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.25]:4592 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754454AbYJBVjZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2008 17:39:25 -0400
Received: by qw-out-2122.google.com with SMTP id 3so293476qwe.37
        for <netdev@vger.kernel.org>; Thu, 02 Oct 2008 14:39:24 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.64.0810030008280.22964@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 3 Oct 2008 00:19:08 +0300 (EEST)
"Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi> wrote:

> Yes yes, I'd be specificly interested to have some rough idea what th=
at
> "some other command" includes, especially as some seem to be non-net=20
> related since you mentioned e.g., that /dev/log thing?

	Ah ok! :)

	Yes, please, take a look at this thread:

http://www.sudo.ws/pipermail/sudo-workers/2008-September/000626.html

	We use strace too and I noticed that it stalled when trying to
access /dev/log (at the end). Does it make sense?

	The sudo guy says it's an UDP connection, so this could explain
why I can't restore it with nmap -sS...=20

	At the end, he thinks it could be a kernel issue... (what I
think too, because it never happened before 2.6.25).

	Any ideas?


--=20
