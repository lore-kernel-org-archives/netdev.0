From: Ingo Molnar <mingo@elte.hu>
Subject: Re: 2.6.24-rc3: find complains about /proc/net
Date: Tue, 20 Nov 2007 22:59:14 +0100
Message-ID: <20071120215914.GE24156@elte.hu>
References: <20071119191000.GA1560@elf.ucw.cz> <200711192304.25087.rjw@sisk.pl> <4743026B.2020907@openvz.org> <m11wakshyz.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pavel Emelyanov <xemul@openvz.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, Pavel Machek <pavel@ucw.cz>,
	kernel list <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:60477 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752113AbXKTV7d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Nov 2007 16:59:33 -0500
Content-Disposition: inline
In-Reply-To: <m11wakshyz.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Eric W. Biederman <ebiederm@xmission.com> wrote:

> > lr-x------  1 root root 64 Nov 20 18:03 3 -> /proc/net
> > ...
> 
> Yes all of those are nasty.  So much for my clever way of implementing 
> these things.  Grr. Simple hacks that almost work!

btw., in case you feel inclined, i recently did some userspace coding 
and found to my surprise that /proc/self points to the parent task, not 
the thread itself (giving threads no real way to examine themselves). If 
you are hacking in this area, would it be a big trouble to add something 
like /proc/self-task/ or something like that? I had to use a raw gettid 
syscall to figure out the TID to get to /proc/*/tasks/TID/sched 
instrumentation info - which is quite a PITA.

	Ingo
