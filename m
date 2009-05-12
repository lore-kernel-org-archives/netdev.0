From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: question about softirqs
Date: Tue, 12 May 2009 11:32:41 +0200
Message-ID: <1242120761.11251.324.camel@twins>
References: <18948.63755.279732.294842@cargo.ozlabs.ibm.com>
	<20090508.234815.127227651.davem@davemloft.net>
	<4A086DB2.8040703@nortel.com>
	<20090511.162436.193717082.davem@davemloft.net>
	<4A08C62F.1050105@nortel.com> <20090512081237.GA16403@elte.hu>
	<1242119578.11251.321.camel@twins>  <20090512092348.GA29796@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	Steven Rostedt <rostedt@goodmis.org>, paulus@samba.org,
	Thomas Gleixner <tglx@linutronix.de>, David Miller <davem@davemloft.net>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
In-Reply-To: <20090512092348.GA29796@elte.hu>
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

On Tue, 2009-05-12 at 11:23 +0200, Ingo Molnar wrote:
> 
> Yeah, that would be "nice". A single IRQ thread plus the process 
> context(s) doing networking might perform well.
> 
> Multiple IRQ threads (softirq and hardirq threads mixed) i'm not so 
> sure about - it's extra context-switching cost.

Sure, that was implied by the getting rid of softirqs ;-), on -rt we
currently suffer this hardirq/softirq thread ping-pong, it sucks.
