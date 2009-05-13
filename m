From: David Miller <davem@davemloft.net>
Subject: Re: question about softirqs
Date: Tue, 12 May 2009 21:45:40 -0700 (PDT)
Message-ID: <20090512.214540.147824481.davem@davemloft.net>
References: <20090512092348.GA29796@elte.hu> <1242120761.11251.324.camel@twins>
	<alpine.DEB.2.00.0905120818290.13234@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: a.p.zijlstra@chello.nl, linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	paulus@samba.org, mingo@elte.hu, tglx@linutronix.de
To: rostedt@goodmis.org
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
In-Reply-To: <alpine.DEB.2.00.0905120818290.13234@gandalf.stny.rr.com>
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

From: Steven Rostedt <rostedt@goodmis.org>
Date: Tue, 12 May 2009 08:20:51 -0400 (EDT)

> I'm going to be playing around with bypassing the net-rx/tx with my 
> network drivers. I'm going to add threaded irqs for my network cards and 
> have the driver threads do the work to get through the tcp/ip stack.
> 
> I'll still keep the softirqs for other cards, but I want to see how fast 
> it speeds things up if I have the driver thread do it.

I think your latency is going to be dreadful.
