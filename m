From: =?ISO-8859-1?Q?D=E2niel?= Fraga <fragabr@gmail.com>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility
 workaround (fwd)
Date: Wed, 1 Oct 2008 17:46:37 -0300
Message-ID: <48e3e1b1.0807c00a.62bc.2b32@mx.google.com>
References: <Pine.LNX.4.64.0810011546371.1034@wrl-59.cs.helsinki.fi>
	<48e3a4e5.0d1d640a.4cd3.06e9@mx.google.com>
	<alpine.LFD.1.10.0810012140360.5549@apollo.tec.linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Cc: Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.172]:36147 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752332AbYJAUqo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 16:46:44 -0400
Received: by wf-out-1314.google.com with SMTP id 27so746555wfd.4
        for <netdev@vger.kernel.org>; Wed, 01 Oct 2008 13:46:43 -0700 (PDT)
In-Reply-To: <alpine.LFD.1.10.0810012140360.5549@apollo.tec.linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 1 Oct 2008 22:05:09 +0200 (CEST)
Thomas Gleixner <tglx@linutronix.de> wrote:

> Lots of things related to timers changed over the last kernel
> versions, but the big changes were 2.6.21 for 32bit and 2.6.24 for
> 64bit, where the high resolution timer were enabled. Since then we
> have only bigfixes and improvements in the timer related code. 2.6.25
> has no fundamental changes in the timer code at all.
> 
> I think your observation vs. ntpd and hrtimer is just a red
> herring. It influences the visibility of the problem by shifting
> timings around, but it does not pinpoint them as the root cause.
> 
> I might be wrong as usual, but in that case I insist on "in dubio pro
> reo". :)

	Ok :) I understand your point ;).

> One possibility to get deeper insight into this problem is to use the
> function tracer and stop it once we notice the wreckage. 
> listenoverflow should be a good point to stop it.

	Ok. I'll do it and return the results.

[*] Kernel Function Tracer

	Thank you very much! :)

	Ps: if we figure it out soon, maybe we can solve this before
2.6.27 final release since Linus said that rc8 would be the last one.

-- 
