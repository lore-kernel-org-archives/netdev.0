From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: question about softirqs
Date: Wed, 13 May 2009 09:55:11 +0400
Message-ID: <20090513055511.GA8529@ioremap.net>
References: <18948.63755.279732.294842@cargo.ozlabs.ibm.com> <20090508.234815.127227651.davem@davemloft.net> <4A086DB2.8040703@nortel.com> <20090511.162436.193717082.davem@davemloft.net> <4A08C62F.1050105@nortel.com> <20090512081237.GA16403@elte.hu> <1242119578.11251.321.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@elte.hu>, Chris Friesen <cfriesen@nortel.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Steven Rostedt <rostedt@goodmis.org>,
	David Miller <davem@davemloft.net>, linuxppc-dev@ozlabs.org,
	paulus@samba.org, netdev@vger.kernel.org
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cs-studio.ru ([195.178.208.66]:50998 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751165AbZEMFzT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 May 2009 01:55:19 -0400
Content-Disposition: inline
In-Reply-To: <1242119578.11251.321.camel@twins>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

On Tue, May 12, 2009 at 11:12:58AM +0200, Peter Zijlstra (a.p.zijlstra@chello.nl) wrote:
> Wouldn't the even better solution be to get rid of softirqs
> all-together?

And move tasklets into some thread context?

Only if we are ready to fix 7 times rescheduling regressions compared to
kernel threads (work queue actually). At least that's how tasklet
behaved compared to work queue 1.5 years ago in the simplest
and quite naive test where tasklet/work rescheduled iself number of
times:

http://marc.info/?l=linux-crypto-vger&m=119462472517405&w=2

-- 
	Evgeniy Polyakov
