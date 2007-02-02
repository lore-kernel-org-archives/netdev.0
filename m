From: Mattia Dongili <malattia@linux.it>
Subject: Re: dynticks + iptables almost stops the boot process [was: Re: 2.6.20-rc6-mm3]
Date: Fri, 2 Feb 2007 21:43:44 +0100
Message-ID: <20070202204344.GB4262@inferi.kami.home>
References: <20070129204528.eb8d695e.akpm@osdl.org> <20070131215241.GB2890@inferi.kami.home> <20070131232130.GC4137@inferi.kami.home> <1170358572.29240.292.camel@localhost.localdomain> <1170360101.29240.297.camel@localhost.localdomain> <20070201211137.GA2830@inferi.kami.home> <1170369202.29240.339.camel@localhost.localdomain> <20070202191802.GA4262@inferi.kami.home> <1170448034.29240.364.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org,
	mingo@redhat.com, netdev@vger.kernel.org,
	netfilter-devel@lists.netfilter.org
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aa012msr.fastwebnet.it ([85.18.95.72]:59365 "EHLO
	aa012msr.fastwebnet.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946060AbXBBUoh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Feb 2007 15:44:37 -0500
Content-Disposition: inline
In-Reply-To: <1170448034.29240.364.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 02, 2007 at 09:27:14PM +0100, Thomas Gleixner wrote:
> On Fri, 2007-02-02 at 20:18 +0100, Mattia Dongili wrote:
> > > May I ask you for another test ? Please turn on high resolution timers
> > > and check, if the same strange behaviour is happening.
> > 
> > Yep, here we go again. Still seeing long stalls but no negative expires
> > offset.
> > Actually one more test I did is disabling my iptables script and the
> > boot process went fine. The script is just:
> 
> Mattia,
> 
> I have it halfways reproducible now and I'm working to find the root
> cause. Thanks for providing the info.

Great, I'm obviously available to test any patch :)

-- 
mattia
:wq!
