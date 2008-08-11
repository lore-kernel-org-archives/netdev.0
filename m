From: David Witbrodt <dawitbro@sbcglobal.net>
Subject: Re: [PATCH diagnostic] Re: HPET regression in 2.6.26 versus 2.6.25 -- RCU problem
Date: Mon, 11 Aug 2008 11:13:29 -0700 (PDT)
Message-ID: <396862.4174.qm@web82107.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	linux-kernel@vger.kernel.org, Yinghai Lu <yhlu.kernel@gmail.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>, netdev <netdev@vger.kernel.org>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web82107.mail.mud.yahoo.com ([209.191.84.220]:48046 "HELO
	web82107.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752681AbYHKSNa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2008 14:13:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>




> So i find this debug feature rather useful and have applied it to 
> tip/core/rcu (and cleaned it up a bit). I renamed the config option to 
> CONFIG_DEBUG_RCU_STALL to make it more in line with usual debug option 
> names. Lets see whether -tip testing finds any false positives.

Hmmm, should have read ALL of the emails first!  Drat...

Just for kicks, I rebuilt using Ingo's version -- since I had manually
pasted Paul's patch, there was the possibility of PEBKAC interference:
no additional output at the lock up.


Dave W.
