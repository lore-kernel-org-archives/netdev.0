From: "Chris Friesen" <cfriesen@nortel.com>
Subject: Re: question about softirqs
Date: Wed, 13 May 2009 13:44:59 -0600
Message-ID: <4A0B233B.8010105@nortel.com>
References: <20090512081237.GA16403@elte.hu> <4A09933B.8010606@nortel.com>
	<874ovpmmdq.fsf@basil.nowhere.org> <4A0AC9EC.6070908@nortel.com>
	<20090513141532.GT19296@one.firstfloor.org>
	<alpine.LFD.2.00.0905131612180.3561@localhost.localdomain>
	<87my9hkrmw.fsf@basil.nowhere.org> <4A0AE19D.9040509@nortel.com>
	<20090513170122.GZ19296@one.firstfloor.org>
	<4A0B19A9.1090206@nortel.com>
	<20090513191354.GB19296@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, netdev@vger.kernel.org,
	Ingo Molnar <mingo@elte.hu>,
	Steven Rostedt <rostedt@goodmis.org>, linuxppc-dev@ozlabs.org,
	paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>,
	David Miller <davem@davemloft.net>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
In-Reply-To: <20090513191354.GB19296@one.firstfloor.org>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:
> On Wed, May 13, 2009 at 01:04:09PM -0600, Chris Friesen wrote:
>> Andi Kleen wrote:
>>
>>> network packets are normally processed by the network packet interrupt's
>>> softirq or alternatively in the NAPI poll loop.
>> If we have a high priority task, ksoftirqd may not get a chance to run.
> 
> In this case the next interrupt will also process them. It will just
> go more slowly because interrupts limit the work compared to ksoftirqd.

I realize that they will eventually get processed.  My point is that the
documentation (in-kernel, online, and in various books) says that
softirqs will be processed _on the return from a syscall_.  As we all
agree, this is not necessarily the case.

Chris
