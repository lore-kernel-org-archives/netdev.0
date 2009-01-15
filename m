From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: deadlocks if use htb
Date: Thu, 15 Jan 2009 12:18:01 +0000
Message-ID: <20090115121801.GH5461@ff.dom.local>
References: <Pine.LNX.4.64.0901110438050.16453@nacho.alt.net> <20090114063909.GA4234@ff.dom.local> <200901141417.58667.denys@visp.net.lb> <1231937404.14825.4.camel@laptop> <Pine.LNX.4.64.0901141748300.17915@nacho.alt.net> <20090115065322.GA4190@ff.dom.local> <Pine.LNX.4.64.0901150724000.20461@nacho.alt.net> <20090115075450.GB4190@ff.dom.local> <20090115094530.GG4190@ff.dom.local> <Pine.LNX.4.64.0901151139440.20461@nacho.alt.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Denys Fedoryschenko <denys@visp.net.lb>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Badalian Vyacheslav <slavon@bigtelecom.ru>,
	Thomas Gleixner <tglx@linutronix.de>
To: Chris Caputo <ccaputo@alt.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f31.google.com ([209.85.219.31]:61595 "EHLO
	mail-ew0-f31.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752791AbZAOMSI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 07:18:08 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0901151139440.20461@nacho.alt.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 15, 2009 at 12:00:50PM +0000, Chris Caputo wrote:
...
> I wish I had a repro scenario in a non-production environment, so I could 
> help out further with this.  If I did, I would test without nmi_watchdog 
> while trying just 2.6.28 and Jarek's #4 patch.

I think this watchdog doesn't matter too much yet. Probably it's more
about hardware (smp, maybe kind of hw timer), and high traffic vs. htb
rules.

Jarek P.
