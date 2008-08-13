From: David Witbrodt <dawitbro@sbcglobal.net>
Subject: Re: HPET regression in 2.6.26 versus 2.6.25 -- experimental revert for 2.6.27 failed
Date: Wed, 13 Aug 2008 10:06:10 -0700 (PDT)
Message-ID: <868545.24711.qm@web82108.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>, netdev <netdev@vger.kernel.org>
To: Yinghai Lu <yhlu.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web82108.mail.mud.yahoo.com ([209.191.84.221]:32522 "HELO
	web82108.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752166AbYHMRGM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2008 13:06:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>




> that patch revert to use request_resource, so there is some other problem

I agree.  I have already begun to bisect to find where the other problem,
which prevents reverting, might have been introduced.  Unfortunately, I'm
on my way to work as soon as I hit the "Send" button on this msg, so I
will be offline for the next 8 hours.


> could apply with
> cat revert_*.;patch | patch -p1

I assumed I should use 'git' to apply the patch.  Using 'git apply' worked
perfectly, though -- 'git status' reported that the files had changed, and
I looked over the files to see if the changes were what were intended by
the patch.  Also, the kernel built without errors.

I'll check it again when I get home, just to be sure, but I think it applied
just fine.


Thanks,
Dave W.
