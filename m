From: Andrew Morton <akpm@osdl.org>
Subject: Re: Fw: Bug: PPP dropouts in >=2.6.16
Date: Wed, 26 Apr 2006 15:07:33 -0700
Message-ID: <20060426150733.53cc9032.akpm@osdl.org>
References: <20060421010809.6c3cfc34.akpm@osdl.org>
	<4807377b0604211015j16b40cccpe215668f8fdcfc24@mail.gmail.com>
	<200604220202.59434.ak@suse.de>
	<20060424074148.GB23340@zion.homelinux.com>
	<Pine.LNX.4.64.0604260126020.12542@pc>
	<20060426212542.GA9287@zion.homelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: lkml@jawad.org, ak@suse.de, jesse.brandeburg@gmail.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:1945 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932407AbWDZWFR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2006 18:05:17 -0400
To: Sven Schuster <schuster.sven@gmx.de>
In-Reply-To: <20060426212542.GA9287@zion.homelinux.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sven Schuster <schuster.sven@gmx.de> wrote:
>
> On Wed, Apr 26, 2006 at 02:36:18AM +0200, Nuri Jawad told us:
> > Did you create a high load on the system in the manner I described?
> > The bug once only appeared after about 6 hours here when line + CPU had 
> > been mostly idle. But that was the longest time between failures. Can you 
> > test with one of the 2.6.16 kernels I tried (latest was .9)? Can't say 
> 
> Unfortunately it seems like plain 2.6.16.x doesn't like the ide
> controller on my (VIA) mainboard, I'm getting I/O errrors on hda
> when booting this kernel (but hard drive works ok with -mm) :-(
> actually I haven't been running a plain stable kernel for a while,
> I've been running -mm kernels for ages...
> 

So there's something in -mm which fixes your kernel?  It's usually the
other way around ;)

And it sounds like something which has been in -mm for a long time, so it
might not be a patch which I was planning on sending upstream.

Can you think of a way in which we can identify which patch does the good
deed?


