From: David Witbrodt <dawitbro@sbcglobal.net>
Subject: Re: HPET regression in 2.6.26 versus 2.6.25 -- found another user with the same regression
Date: Sat, 23 Aug 2008 09:44:17 -0700 (PDT)
Message-ID: <479693.91510.qm@web82107.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Yinghai Lu <yhlu.kernel@gmail.com>,
	Vivek Goyal <vgoyal@redhat.com>,
	Bill Fink <billfink@mindspring.com>,
	linux-kernel@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>, netdev <netdev@vger.kernel.org>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web82107.mail.mud.yahoo.com ([209.191.84.220]:36861 "HELO
	web82107.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752443AbYHWQoS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Aug 2008 12:44:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> sorry about that, my first patch was more broken than i thought (it will 
> basically hang on _any_ box), please try the second patch.

No complaints here.  When I made myself and my machines available to help
with this regression, that included the possibility of errors.

I just send a message with the output of 'dmesg | grep ^ignoring', along
with the full 'dmesg' output gzipped.  My crummy ISP webmail interface
may have choked on it, so if you don't get that output before you see
this, then let me know so I can resend it.  (It's over 100K, though --
should I reduce the CC line first, if I have to resend?)


> Note how the above hack code does a stupid goto, and 'p' is updated for 
> the next loop iteration already. The second version of the debug patch 
> only updates 'p' in the 'continue' case and will hopefully get you much 
> further into bootup!

*sniff*
*wiping tears*

I don't care if you DO make mistakes... I LOVE you guys, man!

If you folks can fix this, then I owe anybody involved a cube of their 
favorite beer!  I'm not a beer drinker myself....  I'll just have green
tea.  ;)


Thanks,
Dave W.
