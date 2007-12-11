From: Ingo Molnar <mingo@elte.hu>
Subject: Re: 2.6.24-rc4-mm1
Date: Tue, 11 Dec 2007 22:20:32 +0100
Message-ID: <20071211212032.GE6902@elte.hu>
References: <20071204211701.994dfce6.akpm@linux-foundation.org> <33307c790712110813h23def95dvd068b7226e9fcd36@mail.gmail.com> <20071211123705.844aac24.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Martin Bligh <mbligh@google.com>, linux-kernel@vger.kernel.org,
	Andy Whitcroft <apw@shadowen.org>, netdev@vger.kernel.org,
	Auke Kok <auke-jan.h.kok@intel.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Roland McGrath <roland@redhat.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:43603 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751692AbXLKVU7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Dec 2007 16:20:59 -0500
Content-Disposition: inline
In-Reply-To: <20071211123705.844aac24.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Andrew Morton <akpm@linux-foundation.org> wrote:

> > I can't see this compile failure posted anywhere:
> > http://test.kernel.org/results/IBM/126049/build/debug/stderr
> > 
> > arch/x86/vdso/vdso32/sigreturn.S: Assembler messages:
> > arch/x86/vdso/vdso32/sigreturn.S:23: Error: suffix or operands invalid for `pop'
> > arch/x86/vdso/vdso32/syscall.S:25: Error: suffix or operands invalid for `pop'
> > make[1]: *** [arch/x86/vdso/vdso32/syscall.o] Error 1
> > make: *** [arch/x86/vdso] Error 2
> 
> (cc Ingo and Thomas)

Roland says:

| That seems like it must be a tool problem.  The V=1 output would show 
| if those compiles missed -m32 or something.  But even in the wrong 
| mode, this error does not make sense.  The assembly code it's citing 
| is identical to the old arch/x86/ia32/vsyscall-syscall.S code.

	Ingo
