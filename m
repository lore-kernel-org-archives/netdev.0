From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: b44: regression in 2.6.22 (resend)
Date: Mon, 28 May 2007 21:23:50 +0200
Message-ID: <1180380230.3657.3.camel@chaos>
References: <20070525172431.60affaca@freepuppy>
	 <200705281714.25841.mb@bu3sch.de> <1180366371.4952.5.camel@chaos>
	 <200705281944.05030.maxi@daemonizer.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	Jeff Garzik <jgarzik@pobox.com>,
	Gary Zambrano <zambrano@broadcom.com>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Maximilian Engelhardt <maxi@daemonizer.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.osadl.org ([213.239.205.134]:59760 "EHLO mail.tglx.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751554AbXE1TXw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 May 2007 15:23:52 -0400
In-Reply-To: <200705281944.05030.maxi@daemonizer.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-05-28 at 19:44 +0200, Maximilian Engelhardt wrote:
> > Can you please keep CONFIG_HIGH_RES_TIMERS and CONFIG_NOHZ and try the
> > following combinations on the kernel command line:
> >
> > 1) highres=off nohz=off (should be the same as your working config)
> > 2) highres=off
> > 3) nohz=off
> 
> I tested this with my 2.6.22-rc3 kernel, here are the results:
> 
> without any special boot parameters: problem does appear
> highres=off nohz=off: problem does not appear
> highres=off: problem does not appear
> nohz=off: problem does appear

Is there any other strange behavior of the high res enabled kernel than
the b44 problem ?

> I additionally built my 2.6.22-rc2-mm1 kernel without High Resolution Timer, 
> but the high ping problem is still there.

Hmm, that's mysterious. Wild guess is that highres exposes the hidden
"feature" in a different way than rc2-mm1 does.

	tglx


