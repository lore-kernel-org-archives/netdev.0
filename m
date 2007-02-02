From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: dynticks + iptables almost stops the boot process [was: Re:
	2.6.20-rc6-mm3]
Date: Fri, 02 Feb 2007 21:27:14 +0100
Message-ID: <1170448034.29240.364.camel@localhost.localdomain>
References: <20070129204528.eb8d695e.akpm@osdl.org>
	 <20070131215241.GB2890@inferi.kami.home>
	 <20070131232130.GC4137@inferi.kami.home>
	 <1170358572.29240.292.camel@localhost.localdomain>
	 <1170360101.29240.297.camel@localhost.localdomain>
	 <20070201211137.GA2830@inferi.kami.home>
	 <1170369202.29240.339.camel@localhost.localdomain>
	 <20070202191802.GA4262@inferi.kami.home>
Reply-To: tglx@linutronix.de
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org,
	mingo@redhat.com, netdev@vger.kernel.org,
	netfilter-devel@lists.netfilter.org
To: Mattia Dongili <malattia@linux.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.osadl.org ([213.239.205.134]:60668 "EHLO mail.tglx.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1423203AbXBBU0Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Feb 2007 15:26:16 -0500
In-Reply-To: <20070202191802.GA4262@inferi.kami.home>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-02-02 at 20:18 +0100, Mattia Dongili wrote:
> > May I ask you for another test ? Please turn on high resolution timers
> > and check, if the same strange behaviour is happening.
> 
> Yep, here we go again. Still seeing long stalls but no negative expires
> offset.
> Actually one more test I did is disabling my iptables script and the
> boot process went fine. The script is just:

Mattia,

I have it halfways reproducible now and I'm working to find the root
cause. Thanks for providing the info.

	tglx


