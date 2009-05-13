From: Andi Kleen <andi@firstfloor.org>
Subject: Re: question about softirqs
Date: Wed, 13 May 2009 17:02:42 +0200
Message-ID: <20090513150242.GX19296@one.firstfloor.org>
References: <20090511.162436.193717082.davem@davemloft.net> <4A08C62F.1050105@nortel.com> <20090512081237.GA16403@elte.hu> <4A09933B.8010606@nortel.com> <874ovpmmdq.fsf@basil.nowhere.org> <4A0AC9EC.6070908@nortel.com> <20090513141532.GT19296@one.firstfloor.org> <alpine.LFD.2.00.0905131612180.3561@localhost.localdomain> <87my9hkrmw.fsf@basil.nowhere.org> <4A0ADF34.2040001@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Chris Friesen <cfriesen@nortel.com>,
	Ingo Molnar <mingo@elte.hu>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Steven Rostedt <rostedt@goodmis.org>,
	David Miller <davem@davemloft.net>, linuxppc-dev@ozlabs.org,
	paulus@samba.org, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:53916 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752139AbZEMO5T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2009 10:57:19 -0400
Content-Disposition: inline
In-Reply-To: <4A0ADF34.2040001@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I have one machine SMP flooded by network frames, CPU0 handling all

Yes that's the case softirqd is supposed to handle. When you 
spend a significant part of your CPU time in softirq context it kicks
in to provide somewhat fair additional CPU time.

But most systems (like mine) don't do that.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
