From: Ingo Molnar <mingo@elte.hu>
Subject: Re: HPET regression in 2.6.26 versus 2.6.25 -- found another user
	with the same regression
Date: Wed, 20 Aug 2008 16:49:49 +0200
Message-ID: <20080820144946.GA829@elte.hu>
References: <958447.6297.qm@web82101.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Yinghai Lu <yhlu.kernel@gmail.com>,
	Bill Fink <billfink@mindspring.com>,
	linux-kernel@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>, netdev <netdev@vger.kernel.org>
To: David Witbrodt <dawitbro@sbcglobal.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:34581 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751842AbYHTOuZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Aug 2008 10:50:25 -0400
Content-Disposition: inline
In-Reply-To: <958447.6297.qm@web82101.mail.mud.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* David Witbrodt <dawitbro@sbcglobal.net> wrote:

> I'm sure that is correct, but can you folks verify that?  A file like 
> apic_32.c (in Ingo's patch above) cannot affect me if I am running a 
> 64-bit architecture, right?

correct - i just commented out from both 32-bit and the 64-bit side to 
have a complete patch. (if someone else who runs a 32-bit kernel picks 
it up for experimentation it will do a similar thing)

	Ingo
