From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility workaround
 (fwd)
Date: Sat, 11 Oct 2008 11:27:50 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0810111121050.18685@wrl-59.cs.helsinki.fi>
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
 <48e8fef7.0610c00a.5fa2.ffffaab0@mx.google.com> <alpine.LFD.2.00.0810052008131.3398@apollo>
 <48ed0b51.0913c00a.7715.4aa7@mx.google.com> <alpine.LFD.2.00.0810082154420.3237@apollo>
 <Pine.LNX.4.64.0810082329250.7599@wrl-59.cs.helsinki.fi>
 <48eed827.060ec00a.1389.ffffb4e3@mx.google.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-1745386194-1223713670=:18685"
Cc: Thomas Gleixner <tglx@linutronix.de>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: "=?ISO-8859-1?Q?D=E2niel?= Fraga" <fragabr@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:41408 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751108AbYJKI1x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Oct 2008 04:27:53 -0400
In-Reply-To: <48eed827.060ec00a.1389.ffffb4e3@mx.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1745386194-1223713670=:18685
Content-Type: TEXT/PLAIN; charset=iso-8859-1
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
> 
> 	and the requested /proc/net/tcp by the time the Tracer was
> stopped:
> 
> http://www.abusar.org/ftrace/trace-tcp.txt
> 
> 	I hope that now it helps.
> 
> 	As always, if you need more information, just ask.

This time there isn't any listening socket with queue to be accepted, not 
connections. So it's not exactly the same situation on the server, I'm 
sort of thinking that the accept() stuff we found earlier is just 
coincidence, I guess it could as well hang somewhere else on other
times.

-- 
 i.
---696208474-1745386194-1223713670=:18685--
