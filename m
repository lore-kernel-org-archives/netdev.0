From: =?ISO-8859-1?Q?D=E2niel?= Fraga <fragabr@gmail.com>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility
 workaround (fwd)
Date: Thu, 2 Oct 2008 11:09:56 -0300
Message-ID: <48e4d63a.060ec00a.6a4e.ffff95bf@mx.google.com>
References: <Pine.LNX.4.64.0810011546371.1034@wrl-59.cs.helsinki.fi>
	<48e3a4e5.0d1d640a.4cd3.06e9@mx.google.com>
	<alpine.LFD.1.10.0810012140360.5549@apollo.tec.linutronix.de>
	<48e3e835.0906c00a.2cd1.2fd1@mx.google.com>
	<alpine.LFD.1.10.0810021142370.5549@apollo.tec.linutronix.de>
	<48e4adb8.0807c00a.62b8.ffff87d6@mx.google.com>
	<alpine.LFD.1.10.0810021407400.5549@apollo.tec.linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Cc: Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.172]:38875 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752561AbYJBOKE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2008 10:10:04 -0400
Received: by wf-out-1314.google.com with SMTP id 27so1121879wfd.4
        for <netdev@vger.kernel.org>; Thu, 02 Oct 2008 07:10:03 -0700 (PDT)
In-Reply-To: <alpine.LFD.1.10.0810021407400.5549@apollo.tec.linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2 Oct 2008 14:08:14 +0200 (CEST)
Thomas Gleixner <tglx@linutronix.de> wrote:

> grmbl. tracer_enabled should have been ftrace_enabled of course.

	Ok Thomas. I got a stall on my desktop.

	It happens when I try to use sudo and it just stay stalled (I
think trying to access /dev/log or something like that).

	I got the trace here:

http://www.abusar.org/ftrace/trace.txt.bz2

	after the stall.

	Could you please check if there's something wrong?

	I'd prefer if the stall happened in the server, but it still
didn't happen. Anyway, it's the same problem.

	Ps: this time I couldn't solve it with nmap (sometimes nmap
solves, sometimes it doesn't).

	Ps2: in this stall, the tracing wasn't disabled automatically
by your patch, because it happened in a different situation (when I
tried to use sudo). But I know it's the same problem, because the
"solution" I use is always the same (nmap) and until it's not stalled
anymore, I can't connect to any port on my machine.

	Ps3: if this trace is useless, wait until I get something on
the server.

-- 
