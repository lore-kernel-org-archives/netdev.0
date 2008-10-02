From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility workaround
 (fwd)
Date: Thu, 2 Oct 2008 21:16:32 +0200 (CEST)
Message-ID: <alpine.LFD.1.10.0810022113540.5549@apollo.tec.linutronix.de>
References: <Pine.LNX.4.64.0810011546371.1034@wrl-59.cs.helsinki.fi> <48e3a4e5.0d1d640a.4cd3.06e9@mx.google.com> <alpine.LFD.1.10.0810012140360.5549@apollo.tec.linutronix.de> <48e3e835.0906c00a.2cd1.2fd1@mx.google.com> <alpine.LFD.1.10.0810021142370.5549@apollo.tec.linutronix.de>
 <48e4adb8.0807c00a.62b8.ffff87d6@mx.google.com> <alpine.LFD.1.10.0810021407400.5549@apollo.tec.linutronix.de> <48e4d63a.060ec00a.6a4e.ffff95bf@mx.google.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-998241439-1222974993=:5549"
Cc: =?ISO-8859-15?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: =?ISO-8859-15?Q?D=E2niel_Fraga?= <fragabr@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.tglx.de ([62.245.132.106]:59167 "EHLO www.tglx.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753264AbYJBTQq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Oct 2008 15:16:46 -0400
In-Reply-To: <48e4d63a.060ec00a.6a4e.ffff95bf@mx.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-998241439-1222974993=:5549
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT

On Thu, 2 Oct 2008, Dâniel Fraga wrote:

> On Thu, 2 Oct 2008 14:08:14 +0200 (CEST)
> Thomas Gleixner <tglx@linutronix.de> wrote:
> 
> > grmbl. tracer_enabled should have been ftrace_enabled of course.
> 
> 	Ok Thomas. I got a stall on my desktop.
> 
> 	It happens when I try to use sudo and it just stay stalled (I
> think trying to access /dev/log or something like that).
> 
> 	I got the trace here:
> 
> http://www.abusar.org/ftrace/trace.txt.bz2
> 
> 	after the stall.
> 
> 	Could you please check if there's something wrong?
> 
> 	I'd prefer if the stall happened in the server, but it still
> didn't happen. Anyway, it's the same problem.

Hmm, not sure. sudo is a different beast. All I can see in the trace
is that reiserfs is turning itself in circles (which is nothing new),
but there is nothing which might tell us about a stall. At the point
where you stopped the trace the relevant info was already replaced by
new stuff. It's a circular buffer which gets overwritten.

Thanks,

	tglx
--8323328-998241439-1222974993=:5549--
