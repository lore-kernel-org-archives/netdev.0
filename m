From: Chris Caputo <ccaputo@alt.net>
Subject: Re: deadlocks if use htb
Date: Wed, 14 Jan 2009 18:02:04 +0000 (UTC)
Message-ID: <Pine.LNX.4.64.0901141748300.17915@nacho.alt.net>
References: <20081010090426.GA6054@ff.dom.local>
	<Pine.LNX.4.64.0901110438050.16453@nacho.alt.net>
	<20090114063909.GA4234@ff.dom.local>
	<200901141417.58667.denys@visp.net.lb>
	<1231937404.14825.4.camel@laptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Denys Fedoryschenko <denys@visp.net.lb>,
	Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Badalian Vyacheslav <slavon@bigtelecom.ru>,
	Thomas Gleixner <tglx@linutronix.de>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754024AbZANSI6@vger.kernel.org>
In-Reply-To: <1231937404.14825.4.camel@laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 14 Jan 2009, Peter Zijlstra wrote:
> On Wed, 2009-01-14 at 14:17 +0200, Denys Fedoryschenko wrote:
> > I will try that patches too, when i got this message, after 3 minutes i got 
> > crash of my router :-) after working around 17 hours :-(
> > There is 3 of them by the way, 2 fixes also.
> > 
> > hrtimer: removing all ur callback modes
> > hrtimer: removing all ur callback modes, fix hotplug
> > hrtimer: removing all ur callback modes, fix
> 
> I'm afraid its a bit more than that:
> 
> ca109491f612aab5c8152207631c0444f63da97f
> 37810659ea7d9572c5ac284ade272f806ef8f788
> a0a99b227da57f81319dd239bc4de811b0f530ec
> b2e3c0adec918ea22b6c9d7c76193dd3aaba9bd4
> 8bdec955b0da2ffbd10eb9b200651dd1f9e366f2
> d5fd43c4ae04523e1dcd7794f9c511b289851350
> 731a55ba0f17064f85903b7bf8e24849ec6cfa20
> a6037b61c2f5fc99c57c15b26d7cfa58bbb34008
> e3f1d883740b09e5116d4d4e30a6a6987264a83c
> 82c5b7b527ccc4b5d3cf832437e842f9d2920a79
> 
> and
> 
> 6e5c172cf7ca1ab878cc6a6a4c1d52fef60f3ee0
> 
> Also, all this is rather invasive and large, so I'm not sure it will
> meet the -stable criteria.

In my testing (another 12 hours of uptime, BTW), the three patches I am 
using are:

  ca109491f612aab5c8152207631c0444f63da97f
  37810659ea7d9572c5ac284ade272f806ef8f788
  a0a99b227da57f81319dd239bc4de811b0f530ec

I have not tried the other patches.

That said, I would not recommend just the three for -stable unless they 
get a much wider amount of testing, on multiple platforms.  I don't see 
that as likely to happen, plus Peter says they are incomplete, so maybe it 
is just best to recommend that 2.6.28 users getting crashes while using 
HTB try these specific patches at first, and then the rest of the patches 
if they do not work.

Thanks,
Chris
