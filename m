From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: deadlocks if use htb
Date: Wed, 14 Jan 2009 13:12:57 +0000
Message-ID: <20090114131257.GC6117@ff.dom.local>
References: <20081010090426.GA6054@ff.dom.local> <200901141417.58667.denys@visp.net.lb> <1231937404.14825.4.camel@laptop> <200901141505.46929.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Chris Caputo <ccaputo@alt.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Badalian Vyacheslav <slavon@bigtelecom.ru>,
	Thomas Gleixner <tglx@linutronix.de>
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f31.google.com ([209.85.219.31]:60186 "EHLO
	mail-ew0-f31.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755365AbZANNNG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 08:13:06 -0500
Content-Disposition: inline
In-Reply-To: <200901141505.46929.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 14, 2009 at 03:05:46PM +0200, Denys Fedoryschenko wrote:
> > I'm afraid its a bit more than that:
> >
> > ca109491f612aab5c8152207631c0444f63da97f
> > 37810659ea7d9572c5ac284ade272f806ef8f788
> > a0a99b227da57f81319dd239bc4de811b0f530ec
> > b2e3c0adec918ea22b6c9d7c76193dd3aaba9bd4
> > 8bdec955b0da2ffbd10eb9b200651dd1f9e366f2
> > d5fd43c4ae04523e1dcd7794f9c511b289851350
> > 731a55ba0f17064f85903b7bf8e24849ec6cfa20
> > a6037b61c2f5fc99c57c15b26d7cfa58bbb34008
> > e3f1d883740b09e5116d4d4e30a6a6987264a83c
> > 82c5b7b527ccc4b5d3cf832437e842f9d2920a79
> >
> > and
> >
> > 6e5c172cf7ca1ab878cc6a6a4c1d52fef60f3ee0
> >
> > Also, all this is rather invasive and large, so I'm not sure it will
> > meet the -stable criteria.
> 
> Then i will try to run 2.6.29-rc1-git4. Kind of risky to run rc1 on loaded 
> router, but i am hitting this bug with hrtimers hardly, so no choice for me 
> seems. And i cannot disable hrtimers because of bad shaper precision.
> Thanks a lot for info and patches :-)
> 

Denys, since these three patches worked for Chris, I guess it's safer
to stay with 2.6.28 anyway (or my patches mentioned earlier in this
thread). rc1 is really not stable...

Jarek P.
