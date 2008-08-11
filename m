From: David Witbrodt <dawitbro@sbcglobal.net>
Subject: Re: [PATCH diagnostic] Re: HPET regression in 2.6.26 versus 2.6.25 -- RCU problem
Date: Mon, 11 Aug 2008 11:22:21 -0700 (PDT)
Message-ID: <173065.89301.qm@web82104.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Zijlstra <peterz@infradead.org>,
	linux-kernel@vger.kernel.org, Yinghai Lu <yhlu.kernel@gmail.com>,
	Ingo Molnar <mingo@elte.hu>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>, netdev <netdev@vger.kernel.org>
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from web82104.mail.mud.yahoo.com ([209.191.84.217]:39339 "HELO
	web82104.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752974AbYHKSWW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2008 14:22:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> > Well, I was hoping to see something interesting.  I ran it with parameters
> > "debug initcall_debug", and it locked up at the same place.  I let it for
> > 15 minutes, in case of some delayed reaction.  Nada.
> 
> Interesting.  The causes could be:
> 
> o    Scheduling-clock interrupts aren't happening, as Ingo suggested.

Does anyone have a short answer to this question:  Were the changes between
2.6.25 and 2.6.26 so major that interrupts are NOW being used that were not
being used before?

Again, I don't even pretend to understand the kernel's inner workings, but
2.6.25 _did_ work on this hardware... and with HPET enabled.


DW
