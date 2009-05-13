From: Andi Kleen <andi@firstfloor.org>
Subject: Re: question about softirqs
Date: Wed, 13 May 2009 16:15:32 +0200
Message-ID: <20090513141532.GT19296@one.firstfloor.org>
References: <18948.63755.279732.294842@cargo.ozlabs.ibm.com> <20090508.234815.127227651.davem@davemloft.net> <4A086DB2.8040703@nortel.com> <20090511.162436.193717082.davem@davemloft.net> <4A08C62F.1050105@nortel.com> <20090512081237.GA16403@elte.hu> <4A09933B.8010606@nortel.com> <874ovpmmdq.fsf@basil.nowhere.org> <4A0AC9EC.6070908@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, Ingo Molnar <mingo@elte.hu>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Thomas Gleixner <tglx@linutronix.de>,
	Steven Rostedt <rostedt@goodmis.org>,
	David Miller <davem@davemloft.net>, linuxppc-dev@ozlabs.org,
	paulus@samba.org, netdev@vger.kernel.org
To: Chris Friesen <cfriesen@nortel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:37001 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752246AbZEMOKK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2009 10:10:10 -0400
Content-Disposition: inline
In-Reply-To: <4A0AC9EC.6070908@nortel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> "If a soft irq is raised in process context, raise_softirq() in
> kernel/softirq.c calls wakeup_softirqd() to make sure that ksoftirqd

softirqd is only used when the softirq runs for too long or when
there are no suitable irq exits for a long time.

In normal situations (not excessive time in softirq) they don't
do anything. 

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
