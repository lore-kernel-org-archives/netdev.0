From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: 2.6.23-rc1: BUG_ON in kmap_atomic_prot()
Date: Thu, 26 Jul 2007 11:19:42 -0700 (PDT)
Message-ID: <alpine.LFD.0.999.0707261119040.3442@woody.linux-foundation.org>
References: <20070723204045.GD5755@martell.zuzino.mipt.ru>
 <20070723210153.GA5753@martell.zuzino.mipt.ru> <20070723141137.171e4ac1.akpm@linux-foundation.org>
 <alpine.LFD.0.999.0707231415511.3607@woody.linux-foundation.org>
 <20070724175951.GC6019@stusta.de> <alpine.LFD.0.999.0707241113180.3607@woody.linux-foundation.org>
 <20070724112843.0cc104c2.akpm@linux-foundation.org>
 <alpine.LFD.0.999.0707241207290.3607@woody.linux-foundation.org>
 <20070724194046.GD6019@stusta.de> <alpine.LFD.0.999.0707241246130.3607@woody.linux-foundation.org>
 <20070726180721.GN3572@stusta.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Adrian Bunk <bunk@stusta.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:42418 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934854AbXGZST6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2007 14:19:58 -0400
In-Reply-To: <20070726180721.GN3572@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Thu, 26 Jul 2007, Adrian Bunk wrote:
> > 
> > So maybe I'm old-fashioned and crazy, but "readability of the asm result" 
> > actually is a worthwhile goal. Not because we care directly, but because 
> > I'd like to encourage people to do it, due to the *indirect* benefits.
> 
> This would lead to people trying to optimize code for one gcc version - 
> and the code might stay this way for 10 years.

No. The fact is, code that is easy to optimize is easy to optimize.

It has _nothing_ to do with gcc versions. 

		Linus
