From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: Linux 3.1-rc9
Date: Wed, 2 Nov 2011 19:30:49 +0100 (CET)
Message-ID: <alpine.LFD.2.02.1111021929310.2829@ionos>
References: <1318879396.4172.92.camel@twins> <alpine.LFD.2.02.1110172237030.3240@ionos> <alpine.LFD.2.02.1110181037120.3240@ionos> <1318928713.21167.4.camel@twins> <20111018182046.GF1309@hostway.ca> <alpine.LFD.2.02.1110182146440.3240@ionos>
 <20111024190203.GA24410@hostway.ca> <20111025202049.GB25043@hostway.ca> <20111031173246.GA10614@hostway.ca> <alpine.LFD.2.02.1111021725550.2829@ionos> <20111102182812.GE5971@hostway.ca>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Dave Jones <davej@redhat.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Ingo Molnar <mingo@elte.hu>,
	Network Development <netdev@vger.kernel.org>
To: Simon Kirby <sim@hostway.ca>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111102182812.GE5971@hostway.ca>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2 Nov 2011, Simon Kirby wrote:
> On Wed, Nov 02, 2011 at 05:40:53PM +0100, Thomas Gleixner wrote:
> Ok, I'll try this. Hmm, all CPUs typically try to grab the lock fairly
> quickly after it happens, which could make it difficult to cat the file.
> I'll try ftrace_dump(DUMP_ALL); in there instead.

Eric has spotted the source of trouble already. Can you try his patch
first? If it still persists, we still can resort to hardcore tracing :)

Thanks,

	tglx
