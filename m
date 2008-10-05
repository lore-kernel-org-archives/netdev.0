From: =?ISO-8859-1?Q?D=E2niel?= Fraga <fragabr@gmail.com>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility
 workaround (fwd)
Date: Sun, 5 Oct 2008 16:31:13 -0300
Message-ID: <48e91606.0906c00a.2cd5.6a33@mx.google.com>
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
	<48e8fef7.0610c00a.5fa2.ffffaab0@mx.google.com>
	<alpine.LFD.2.00.0810052008131.3398@apollo>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Cc: Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.25]:38282 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755690AbYJETbV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Oct 2008 15:31:21 -0400
Received: by qw-out-2122.google.com with SMTP id 3so526223qwe.37
        for <netdev@vger.kernel.org>; Sun, 05 Oct 2008 12:31:20 -0700 (PDT)
In-Reply-To: <alpine.LFD.2.00.0810052008131.3398@apollo>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 5 Oct 2008 20:09:22 +0200 (CEST)
Thomas Gleixner <tglx@linutronix.de> wrote:

> did you get the content of /debug/tracing/trace nevertheless ?

	Yes! I got several... maybe one is valid....

> The cat /debug/tracing/tracing_enabled == 1 might be just a user space
> interface thingy.

	Ok, here they are (I hope one of them is correct):

http://www.abusar.org/ftrace/

	These ones I get after I saw the kernel message "Tracer
stopped".

http://www.abusar.org/ftrace/trace.txt.bz2

http://www.abusar.org/ftrace/trace2.txt.bz2

http://www.abusar.org/ftrace/trace3.txt.bz2

http://www.abusar.org/ftrace/trace4.txt.bz2

http://www.abusar.org/ftrace/trace5.txt.bz2

	These ones were during a stall and after a nmap:

http://www.abusar.org/ftrace/trace-stop.txt.bz2

http://www.abusar.org/ftrace/trace-stop2.txt.bz2

	If none of these is valid, I will use monit to
check for Tracer stopped and force the tracing to be disabled.

-- 
