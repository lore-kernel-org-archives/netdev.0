From: Chris Caputo <ccaputo@alt.net>
Subject: Re: deadlocks if use htb
Date: Thu, 15 Jan 2009 13:53:09 +0000 (UTC)
Message-ID: <Pine.LNX.4.64.0901151340540.20461@nacho.alt.net>
References: <Pine.LNX.4.64.0901110438050.16453@nacho.alt.net>
	<20090114063909.GA4234@ff.dom.local>
	<200901141417.58667.denys@visp.net.lb>
	<1231937404.14825.4.camel@laptop>
	<Pine.LNX.4.64.0901141748300.17915@nacho.alt.net>
	<20090115065322.GA4190@ff.dom.local>
	<Pine.LNX.4.64.0901150724000.20461@nacho.alt.net>
	<20090115075450.GB4190@ff.dom.local>
	<20090115094530.GG4190@ff.dom.local>
	<Pine.LNX.4.64.0901151139440.20461@nacho.alt.net>
	<20090115121801.GH5461@ff.dom.local>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Denys Fedoryschenko <denys@visp.net.lb>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Badalian Vyacheslav <slavon@bigtelecom.ru>
To: Jarek Poplawski <jarkao2@gmail.com>,
	Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762321AbZAONx2@vger.kernel.org>
In-Reply-To: <20090115121801.GH5461@ff.dom.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 15 Jan 2009, Jarek Poplawski wrote:
> On Thu, Jan 15, 2009 at 12:00:50PM +0000, Chris Caputo wrote:
> ...
> > I wish I had a repro scenario in a non-production environment, so I could 
> > help out further with this.  If I did, I would test without nmi_watchdog 
> > while trying just 2.6.28 and Jarek's #4 patch.
> 
> I think this watchdog doesn't matter too much yet. Probably it's more
> about hardware (smp, maybe kind of hw timer), and high traffic vs. htb
> rules.

Per Thomas' comment in http://bugzilla.kernel.org/show_bug.cgi?id=10944 
regarding broken hrtimers:

--
  nmi_watchdog=1 disables the local apic timers and therefor highres/nohz

  Try to use nmi_watchdog=2 instead.
--

Chris
