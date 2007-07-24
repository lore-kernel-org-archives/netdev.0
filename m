From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: 2.6.23-rc1: BUG_ON in kmap_atomic_prot()
Date: Tue, 24 Jul 2007 12:45:32 -0700 (PDT)
Message-ID: <alpine.LFD.0.999.0707241244140.3607@woody.linux-foundation.org>
References: <alpine.LFD.0.999.0707221351030.3607@woody.linux-foundation.org>
 <20070723183839.GA5874@martell.zuzino.mipt.ru> <20070723190152.GA5755@martell.zuzino.mipt.ru>
 <20070723132431.42afbae8.akpm@linux-foundation.org>
 <20070723204045.GD5755@martell.zuzino.mipt.ru> <20070723210153.GA5753@martell.zuzino.mipt.ru>
 <20070723141137.171e4ac1.akpm@linux-foundation.org>
 <alpine.LFD.0.999.0707231415511.3607@woody.linux-foundation.org>
 <20070724175951.GC6019@stusta.de> <alpine.LFD.0.999.0707241113180.3607@woody.linux-foundation.org>
 <20070724112843.0cc104c2.akpm@linux-foundation.org>
 <alpine.LFD.0.999.0707241207290.3607@woody.linux-foundation.org>
 <p73r6mxsg2o.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Adrian Bunk <bunk@stusta.de>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:60838 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761588AbXGXTqE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2007 15:46:04 -0400
In-Reply-To: <p73r6mxsg2o.fsf@bingen.suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Tue, 24 Jul 2007, Andi Kleen wrote:
> 
> There's probably a --param where it can be tweaked exactly. The
> problem is that --params tend to be very gcc version specific
> and might do something completely different on a newer or 
> older version. So it's better not to use them.

I agree wholeheartedly with that sentiment. We've tried at times (because 
some gcc snapshots made some *truly* insane choices for a while), and 
maybe we still have some around. Not worth the pain.

		Linus
