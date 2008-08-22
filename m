From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: build issue #564 for v2.6.27-rc4 : undefined reference to
 `NS8390p_init'
Date: Fri, 22 Aug 2008 11:09:02 -0700
Message-ID: <20080822110902.432dd99e.akpm@linux-foundation.org>
References: <200808221033.46997.toralf.foerster@gmx.de>
	<Pine.LNX.4.64.0808221025070.6100@shark.he.net>
	<20080822181234.2f33e993@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: rdunlap@xenotime.net, toralf.foerster@gmx.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jgarzik@pobox.com
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:34144 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752838AbYHVSJm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2008 14:09:42 -0400
In-Reply-To: <20080822181234.2f33e993@lxorguk.ukuu.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 22 Aug 2008 18:12:34 +0100
Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:

> O> > drivers/built-in.o: In function `wd_probe1':
> > > wd.c:(.init.text+0x2570): undefined reference to `NS8390p_init'
> > > make: *** [.tmp_vmlinux1] Error 1
> > 
> > Alan,
> > 
> > Do you have any outstanding patches for these wd (and I've seen
> > hp-plus as well IIRC) build issues, or should Jeff have them now?
> 
> I'm not really tracking it any more, there were so many patches from so
> many people I couldn't give a definitive answer as to what was applied,
> is queued or is not queued.
> 

For the record, and from memory, there were three patches.

One from you which broke my tree.

One from Randy which I merged after several days of you not responding
to our bug reports.

One which I typed in by hand based upon your lackadaisical,
several-month-late English-language description of what I needed to do
to fix it.  As we can see, it didn't work.

I wish Jeff hadn't merged the thing after I dropped it - I sat on it
for months waiting in exhasperation for you to actually support your
own work and you never did.

Can we just revert it now?
