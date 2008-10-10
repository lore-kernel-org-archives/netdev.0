From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility workaround
 (fwd)
Date: Fri, 10 Oct 2008 10:10:30 +0200 (CEST)
Message-ID: <alpine.LFD.2.00.0810101006580.3271@apollo>
References: <Pine.LNX.4.64.0810011546371.1034@wrl-59.cs.helsinki.fi> <48e3a4e5.0d1d640a.4cd3.06e9@mx.google.com> <alpine.LFD.1.10.0810012140360.5549@apollo.tec.linutronix.de> <48e3e835.0906c00a.2cd1.2fd1@mx.google.com> <alpine.LFD.1.10.0810021142370.5549@apollo.tec.linutronix.de>
 <48e4adb8.0807c00a.62b8.ffff87d6@mx.google.com> <alpine.LFD.1.10.0810021407400.5549@apollo.tec.linutronix.de> <48e4d63a.060ec00a.6a4e.ffff95bf@mx.google.com> <alpine.LFD.1.10.0810022113540.5549@apollo.tec.linutronix.de> <Pine.LNX.4.64.0810022251400.22964@wrl-59.cs.helsinki.fi>
 <48e5364d.0603c00a.6e25.fffff993@mx.google.com> <Pine.LNX.4.64.0810030008280.22964@wrl-59.cs.helsinki.fi> <48e8fef7.0610c00a.5fa2.ffffaab0@mx.google.com> <alpine.LFD.2.00.0810052008131.3398@apollo> <48ed0b51.0913c00a.7715.4aa7@mx.google.com>
 <alpine.LFD.2.00.0810082154420.3237@apollo> <Pine.LNX.4.64.0810082329250.7599@wrl-59.cs.helsinki.fi> <48eed827.060ec00a.1389.ffffb4e3@mx.google.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-2059757693-1223626233=:3271"
Cc: =?ISO-8859-15?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: =?ISO-8859-15?Q?D=E2niel_Fraga?= <fragabr@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.tglx.de ([62.245.132.106]:44401 "EHLO www.tglx.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751340AbYJJIKy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Oct 2008 04:10:54 -0400
In-Reply-To: <48eed827.060ec00a.1389.ffffb4e3@mx.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-2059757693-1223626233=:3271
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Fri, 10 Oct 2008, Dâniel Fraga wrote:

> On Wed, 8 Oct 2008 23:44:39 +0300 (EEST)
> "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi> wrote:
> 
> > the server (we don't have /proc/net/tcp of that case so I cannot 
> 
> 	Ok, now I got a trace that I think is the best one I got so far:
> 
> http://www.abusar.org/ftrace/trace-best.txt.bz2

Nothing which helps us really :( We stop the trace too late
and probably we need some dedicated tracepoints to see something
useful. I'm away over the weekend, but I might have some time to look
into that.

Thanks,

	tglx

--8323328-2059757693-1223626233=:3271--
