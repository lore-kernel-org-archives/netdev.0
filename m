From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: deadlocks if use htb
Date: Thu, 15 Jan 2009 08:09:21 +0000
Message-ID: <20090115080921.GC4190@ff.dom.local>
References: <20081010090426.GA6054@ff.dom.local> <Pine.LNX.4.64.0901110438050.16453@nacho.alt.net> <20090114063909.GA4234@ff.dom.local> <200901141417.58667.denys@visp.net.lb> <1231937404.14825.4.camel@laptop> <Pine.LNX.4.64.0901141748300.17915@nacho.alt.net> <20090115065322.GA4190@ff.dom.local> <496EE1D4.6010709@bigtelecom.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chris Caputo <ccaputo@alt.net>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Denys Fedoryschenko <denys@visp.net.lb>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Thomas Gleixner <tglx@linutronix.de>
To: Badalian Vyacheslav <slavon@bigtelecom.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f31.google.com ([209.85.219.31]:64747 "EHLO
	mail-ew0-f31.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756397AbZAOIJ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 03:09:28 -0500
Content-Disposition: inline
In-Reply-To: <496EE1D4.6010709@bigtelecom.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 15, 2009 at 10:12:20AM +0300, Badalian Vyacheslav wrote:
...
> Hello all.
> I also can say this, maybe its help:
> At old kernels my servers do 100% soft interupt if traffic more 600mbs.
> Without your patches at new kernel i get crash only at heavy network
> load PCs (more then 400mbs-500mbs). Servers that get 100-200 mbs not
> crashed long time.
> I remember that i not test patch #4, because you sat what its only
> another way to temporary fix and mainline problem in hrtimer , but i try
> turn on HiRes and Dynamic Tics in kernel - its not help for me.

Slavon, I'm very glad of your testing and reporting, and I never
expected you test anything on production, when something else works
for you. On the other hand, what works for you could be unacceptable
for other users, who don't have such crashes, and prefer better
exactness. So it's hard to recommend such patches if there is not
enough people interested in them.

Best regards,
Jarek P.
