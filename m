From: David Witbrodt <dawitbro@sbcglobal.net>
Subject: Re: HPET regression in 2.6.26 versus 2.6.25 -- revert for 2.6.26-rc1 failed
Date: Thu, 14 Aug 2008 11:11:37 -0700 (PDT)
Message-ID: <798351.12728.qm@web82105.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bill Fink <billfink@mindspring.com>, linux-kernel@vger.kernel.org,
	Ingo Molnar <mingo@elte.hu>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>, netdev <netdev@vger.kernel.org>
To: Yinghai Lu <yhlu.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web82105.mail.mud.yahoo.com ([209.191.84.218]:43657 "HELO
	web82105.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751855AbYHNSLi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2008 14:11:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> can you try enable kexec and kdump in you .config.
> 
> it should works. my .config have config_kexec

First, I apologize.  I see that you were assuming I had KEXEC enabled when you
gave me the patch against 2.6.27-rc3.  I have only posted parts of my custom
.config to LKML, thinking that posting the whole thing was not appropriate.

Did you mean CRASH_DUMP instead of "kdump" above?

[N] kexec system call    (CONFIG_KEXEC)  (bool)  (Help)
[N] kernel crash dumps (EXPERIMENTAL)    (CONFIG_CRASH_DUMP)  (bool)  (Help)

My custom .config has both of these disabled -- either because they default
to "N" when running 'make oldconfig', or because I read the help text with
those options and decided I would not be using those features.


> > Some experiments I did last night may render these questions moot, though.
> > My problem is very specific to the hardware on two of my machines, and it
> > has something to do with setting up the system resources that
> > insert_resource() touches.
> 
> please try to bisect on current tree. and every time apply the revert patch...

I will try your patch against 2.6.27-rc3 again, with KEXEC and CRASH_DUMP 
enabled, when I get home from work.  I still have not retried using 'patch'
instead of 'git apply', though I am sure that 'git apply' worked just fine.

I was trying other experiments last night, and have posted the results of
those already -- and I'm guessing that your 2.6.27-rc3 patch will not work
unless it factors in what I discovered there.  (But I will do all of these
changes that you asked, as well.)

I do not know how to bisect with your patch if I have a "bad" but no "good"
to start with.  Can you explain how I should proceed when I _do_ get home?
(I can just enabled those config options and try the patch again, but I am
confused about the bisect you are asking me to perform.)

Does my other post, about trying to revert those February commits, mean
anything?


Thanks,
Dave W.
