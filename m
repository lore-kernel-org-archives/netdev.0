From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: 2.6.23-rc1: BUG_ON in kmap_atomic_prot()
Date: Wed, 25 Jul 2007 00:05:28 +0400
Message-ID: <20070724200528.GA5814@martell.zuzino.mipt.ru>
References: <alpine.LFD.0.999.0707221351030.3607@woody.linux-foundation.org> <20070723183839.GA5874@martell.zuzino.mipt.ru> <20070723190152.GA5755@martell.zuzino.mipt.ru> <20070723132431.42afbae8.akpm@linux-foundation.org> <1185271269.6479.7.camel@Homer.simpson.net> <20070724092839.f0556948.akpm@linux-foundation.org> <alpine.LFD.0.999.0707241124220.3607@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Mike Galbraith <efault@gmx.de>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Christoph Lameter <clameter@sgi.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:26075 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932114AbXGXUFg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2007 16:05:36 -0400
Received: by ug-out-1314.google.com with SMTP id j3so217603ugf
        for <netdev@vger.kernel.org>; Tue, 24 Jul 2007 13:05:35 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <alpine.LFD.0.999.0707241124220.3607@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 24, 2007 at 11:25:22AM -0700, Linus Torvalds wrote:
> On Tue, 24 Jul 2007, Andrew Morton wrote:
> > I guess this was the bug:
>
> Looks very likely to me. Mike, Alexey, does this fix things for you?

Yeah, box is running for more than hour, survived LTP, gdb testsuite,
portage sync and so on.

What new to me is that someone decided TSC is unstable but that's
probably OK on full debug kernel:

	Clocksource tsc unstable (delta = 91724418 ns)
	Time: pit clocksource has been installed.

