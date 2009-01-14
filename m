From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: deadlocks if use htb
Date: Wed, 14 Jan 2009 13:57:06 +0000
Message-ID: <20090114135706.GE6117@ff.dom.local>
References: <20081010090426.GA6054@ff.dom.local> <200901141417.58667.denys@visp.net.lb> <1231937404.14825.4.camel@laptop> <200901141505.46929.denys@visp.net.lb> <20090114131257.GC6117@ff.dom.local> <1231938929.14825.6.camel@laptop> <20090114132603.GD6117@ff.dom.local> <1231939946.14825.9.camel@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Denys Fedoryschenko <denys@visp.net.lb>,
	Chris Caputo <ccaputo@alt.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Badalian Vyacheslav <slavon@bigtelecom.ru>,
	Thomas Gleixner <tglx@linutronix.de>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f31.google.com ([209.85.219.31]:41351 "EHLO
	mail-ew0-f31.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751316AbZANN5O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 08:57:14 -0500
Content-Disposition: inline
In-Reply-To: <1231939946.14825.9.camel@laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 14, 2009 at 02:32:26PM +0100, Peter Zijlstra wrote:
> On Wed, 2009-01-14 at 13:26 +0000, Jarek Poplawski wrote:
> 
> > OK, I hope Denys can apply more, but what about others? Without any
> > patches the hole seems to be much bigger.
> 
> OK, I read most of this thread on netdev, but didn't find a clear clue
> on the specific hrtimer insertion race.
> 
> Do you have any clear ideas or should I poke at the htb/hrtimer code a
> little?
> 

I didn't diagnose this entirely, and there were "a few" days since I
wrote my opinion on this, so currently I forgot details, but I guess
the most suspicious place is adding a hrtimer, when it's on the list,
maybe even two times in a row. I guess it's not removed from the
rbtree in some case. (I stopped searching after seeing you removed
this list or something...)

Jarek P.
