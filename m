From: Andi Kleen <andi@firstfloor.org>
Subject: Re: 2.6.23-rc1: BUG_ON in kmap_atomic_prot()
Date: 24 Jul 2007 22:27:11 +0200
Message-ID: <p73r6mxsg2o.fsf@bingen.suse.de>
References: <alpine.LFD.0.999.0707221351030.3607@woody.linux-foundation.org>
	<20070723183839.GA5874@martell.zuzino.mipt.ru>
	<20070723190152.GA5755@martell.zuzino.mipt.ru>
	<20070723132431.42afbae8.akpm@linux-foundation.org>
	<20070723204045.GD5755@martell.zuzino.mipt.ru>
	<20070723210153.GA5753@martell.zuzino.mipt.ru>
	<20070723141137.171e4ac1.akpm@linux-foundation.org>
	<alpine.LFD.0.999.0707231415511.3607@woody.linux-foundation.org>
	<20070724175951.GC6019@stusta.de>
	<alpine.LFD.0.999.0707241113180.3607@woody.linux-foundation.org>
	<20070724112843.0cc104c2.akpm@linux-foundation.org>
	<alpine.LFD.0.999.0707241207290.3607@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Adrian Bunk <bunk@stusta.de>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.suse.de ([195.135.220.2]:53443 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754507AbXGXTcW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jul 2007 15:32:22 -0400
In-Reply-To: <alpine.LFD.0.999.0707241207290.3607@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linus Torvalds <torvalds@linux-foundation.org> writes:
> 
> So "called once" should probably make the inlining weight bigger (ie 
> inline *larger* functions than you would otherwise), it just shouldn't 
> make it "infinite". It's not worth it.

There's probably a --param where it can be tweaked exactly. The
problem is that --params tend to be very gcc version specific
and might do something completely different on a newer or 
older version. So it's better not to use them.

-Andi
