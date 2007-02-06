From: Mattia Dongili <malattia@linux.it>
Subject: Re: dynticks + iptables almost stops the boot process [was: Re: 2.6.20-rc6-mm3]
Date: Tue, 6 Feb 2007 20:28:40 +0100
Message-ID: <20070206192840.GB2971@inferi.kami.home>
References: <20070131215241.GB2890@inferi.kami.home> <20070131232130.GC4137@inferi.kami.home> <1170358572.29240.292.camel@localhost.localdomain> <1170360101.29240.297.camel@localhost.localdomain> <20070201211137.GA2830@inferi.kami.home> <1170369202.29240.339.camel@localhost.localdomain> <20070202191802.GA4262@inferi.kami.home> <1170448034.29240.364.camel@localhost.localdomain> <20070202204344.GB4262@inferi.kami.home> <20070206164826.GA3491@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Gleixner <tglx@linutronix.de>,
	Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org,
	mingo@redhat.com, netdev@vger.kernel.org,
	netfilter-devel@lists.netfilter.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aa014msr.fastwebnet.it ([85.18.95.74]:39790 "EHLO
	aa014msr.fastwebnet.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965344AbXBFT3E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Feb 2007 14:29:04 -0500
Content-Disposition: inline
In-Reply-To: <20070206164826.GA3491@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 06, 2007 at 05:48:26PM +0100, Ingo Molnar wrote:
> 
> Mattia,
> 
> * Mattia Dongili <malattia@linux.it> wrote:
> 
> > > I have it halfways reproducible now and I'm working to find the root 
> > > cause. Thanks for providing the info.
> > 
> > Great, I'm obviously available to test any patch :)
> 
> Could you try the patch below? The RCU serialization code (a rare call 
> but can be common in some types of setups) has a nasty implicit 
> dependency on the HZ tick - which until now was a hidden wart but became 
> an explicit bug under dynticks. Maybe this is what is slowing down your 
> box.

No, not this. Anyway the last patch Thomas forwarded does fix the
problem.

By the way, I have all the patches I received stacked up, if you want me
to test some different combination, just ask.

Thanks
-- 
mattia
:wq!
