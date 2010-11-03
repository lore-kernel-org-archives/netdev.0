From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: 2.6.35->2.6.36 regression, vanilla kernel panic, ppp or
	hrtimers crashing
Date: Wed, 3 Nov 2010 07:38:54 +0000
Message-ID: <20101103073854.GA7279@ff.dom.local>
References: <20101028070550.GA7647@ff.dom.local> <201011021549.47466.nuclearcat@nuclearcat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Gleixner <tglx@linutronix.de>,
	Paul Mackerras <paulus@samba.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:52792 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753378Ab0KCHjH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Nov 2010 03:39:07 -0400
Content-Disposition: inline
In-Reply-To: <201011021549.47466.nuclearcat@nuclearcat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 02, 2010 at 03:49:47PM +0200, Denys Fedoryshchenko wrote:
> I didn't try yet, but i enable more debugs and catch linked list corruption. 

It should be very useful but it seems there were no significant changes
in ppp locking between 2.6.35 and .36 except the patch I mentioned, so
it would be nice to check this first and try to fix it properly later.

Jarek P.

> 
> Here is dumps from netconsole:
> http://www.nuclearcat.com/ll.txt
> http://www.nuclearcat.com/ll2.txt		
> 
> I have another PC, also fails to run 2.6.36, but netconsole don't give 
> anything.
> Both PC's have strange issue with clock drifting away too much (on 2.6.35 and 
> maybe even before).
> 
> 
> On Thursday 28 October 2010 10:05:50 Jarek Poplawski wrote:
> > On 2010-10-25 11:22, Denys Fedoryshchenko wrote:
> > > Hi
> > > 
> > > Here is what i got from netconsole
> > > 
> > >  [  259.238755] BUG: unable to handle kernel
> > >  paging request
> > >  at f8ba001c
> > >  [  259.238953] IP:
> > >  [<c0199ebe>] do_select+0x2cc/0x502
> > 
> > ...
> > 
> > > It is not easy to do full git bisect(it is semi-embedded distro), but i
> > > can try reversing particular commits, if someone can give idea which
> > > one, and can try debug patches.
> > 
> > Hi,
> > Nothing concrete, but you might try reverting this one:
> > 
> > http://git.kernel.org/?p=linux/kernel/git/stable/linux-2.6.36.y.git;a=commi
> > tdiff;h=15fd0cd9a2ad24a78fbee369dec8ca660979d57e
> > 
> > Jarek P.
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
