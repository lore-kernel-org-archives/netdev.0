From: "Chris Friesen" <cfriesen@nortel.com>
Subject: Re: question about softirqs
Date: Wed, 13 May 2009 13:04:09 -0600
Message-ID: <4A0B19A9.1090206@nortel.com>
References: <20090511.162436.193717082.davem@davemloft.net> <4A08C62F.1050105@nortel.com> <20090512081237.GA16403@elte.hu> <4A09933B.8010606@nortel.com> <874ovpmmdq.fsf@basil.nowhere.org> <4A0AC9EC.6070908@nortel.com> <20090513141532.GT19296@one.firstfloor.org> <alpine.LFD.2.00.0905131612180.3561@localhost.localdomain> <87my9hkrmw.fsf@basil.nowhere.org> <4A0AE19D.9040509@nortel.com> <20090513170122.GZ19296@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Steven Rostedt <rostedt@goodmis.org>,
	David Miller <davem@davemloft.net>, linuxppc-dev@ozlabs.org,
	paulus@samba.org, netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zrtps0kp.nortel.com ([47.140.192.56]:65447 "EHLO
	zrtps0kp.nortel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754053AbZEMTEU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2009 15:04:20 -0400
In-Reply-To: <20090513170122.GZ19296@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi Kleen wrote:

> network packets are normally processed by the network packet interrupt's
> softirq or alternatively in the NAPI poll loop.

If we have a high priority task, ksoftirqd may not get a chance to run.

My point is simply that the documentation says that softirqs are
processed on return from a syscall, and this is not necessarily the case.

Chris
