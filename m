From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Top 10 kernel oopses for the week ending January 5th, 2008
Date: Tue, 08 Jan 2008 18:08:04 +0100
Message-ID: <p73bq7wqm8b.fsf@bingen.suse.de>
References: <477FF149.4070609@linux.intel.com>
	<20080105213935.GN27894@ZenIV.linux.org.uk>
	<20080107174431.GC27741@fieldses.org> <4782CF9C.6000508@gmail.com>
	<alpine.LFD.1.00.0801071851120.3148@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kevin Winchester <kjwinchester@gmail.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Al Viro <viro@ZenIV.linux.org.uk>,
	Arjan van de Ven <arjan@linux.intel.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	NetDev <netdev@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:47941 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752909AbYAHRIH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jan 2008 12:08:07 -0500
In-Reply-To: <alpine.LFD.1.00.0801071851120.3148@woody.linux-foundation.org> (Linus Torvalds's message of "Mon\, 7 Jan 2008 19\:26\:12 -0800 \(PST\)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Linus Torvalds <torvalds@linux-foundation.org> writes:
>
> I usually just compile a small program like

Just use scripts/decodecode and cat the Code line into that.

> particularly good way to do it, and the old "ksymoops" program used to do 
> a pretty good job of this, but I'm used to that particular idiotic way 
> myself, since it's how I've basically always done it)
>
> After that, you still need to try to match up the assembly code with the 
> source code and figure out what variables the register contents actually 
> are all about. You can often try to do a
>
> 	make the/affected/file.s


IMHO better is  

make the/file/xyz.lst        

which gives you a listing with binary data in there which can be
grepped for.

But you should install a very recent binutils because older objdump -S
couldn't deal with unit-at-a-time compilers.

-Andi
