From: =?ISO-8859-1?Q?D=E2niel?= Fraga <fragabr@gmail.com>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility
 workaround (fwd)
Date: Thu, 2 Oct 2008 08:17:01 -0300
Message-ID: <48e4adb8.0807c00a.62b8.ffff87d6@mx.google.com>
References: <Pine.LNX.4.64.0810011546371.1034@wrl-59.cs.helsinki.fi>
	<48e3a4e5.0d1d640a.4cd3.06e9@mx.google.com>
	<alpine.LFD.1.10.0810012140360.5549@apollo.tec.linutronix.de>
	<48e3e835.0906c00a.2cd1.2fd1@mx.google.com>
	<alpine.LFD.1.10.0810021142370.5549@apollo.tec.linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Cc: Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f16.google.com ([209.85.217.16]:39778 "EHLO
	mail-gx0-f16.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753402AbYJBLRO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2008 07:17:14 -0400
Received: by gxk9 with SMTP id 9so1218998gxk.13
        for <netdev@vger.kernel.org>; Thu, 02 Oct 2008 04:17:13 -0700 (PDT)
In-Reply-To: <alpine.LFD.1.10.0810021142370.5549@apollo.tec.linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2 Oct 2008 12:42:44 +0200 (CEST)
Thomas Gleixner <tglx@linutronix.de> wrote:

>   echo sym-verbose > /debug/tracing/iter_ctrl

	Ok, this one I changed to:

echo verbose > /debug/tracing/iter_ctrl

	;) since there's no sym-verbose.

> Find below a patch which disables the tracer when the listen overflow
> is detected. It could occassionally be hit in a legimate case as well,
> but we did not come up with any better idea.

	Ok, I applied the patch, but it returns this error:

  CC      kernel/trace/ftrace.o
kernel/trace/ftrace.c: In function 'stop_event_tracer_now':
kernel/trace/ftrace.c:73: error: 'tracer_enabled' undeclared (first use in this function)
kernel/trace/ftrace.c:73: error: (Each undeclared identifier is reported only once
kernel/trace/ftrace.c:73: error: for each function it appears in.)
make[2]: *** [kernel/trace/ftrace.o] Error 1
make[1]: *** [kernel/trace] Error 2
make: *** [kernel] Error 2

> If it triggers, please cat /debug/tracing/trace to a file. Can you
> bzip2 and upload it to some place. The trace does not contain any
> sensible private information.

	Ok. Thanks.
-- 
