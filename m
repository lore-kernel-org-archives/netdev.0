From: lm@bitmover.com (Larry McVoy)
Subject: Re: tcp bw in 2.6
Date: Mon, 1 Oct 2007 19:20:59 -0700
Message-ID: <20071002022059.GE7037@bitmover.com>
References: <20070929142517.EC6AB5FB21@work.bitmover.com> <alpine.LFD.0.999.0709290914410.3579@woody.linux-foundation.org> <20070929172639.GB7037@bitmover.com> <alpine.LFD.0.999.0709291050200.3579@woody.linux-foundation.org> <20071002005917.GB5480@bitmover.com> <alpine.LFD.0.999.0710011858400.3579@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Larry McVoy <lm@bitmover.com>, davem@davemloft.net,
	wscott@bitmover.com, netdev@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ipcop.bitmover.com ([192.132.92.15]:42259 "EHLO
	mail.bitmover.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751723AbXJBCVA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2007 22:21:00 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LFD.0.999.0710011858400.3579@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 01, 2007 at 07:14:37PM -0700, Linus Torvalds wrote:
> 
> 
> On Mon, 1 Oct 2007, Larry McVoy wrote:
> > 
> > but the client looks like
> > 
> > connect(3, {sa_family=AF_INET, sin_port=htons(31235), sin_addr=inet_addr("10.3.9.1")}, 16) = 0
> > read(3, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 1048576) = 2896
> > read(3, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 1048576) = 1448
> > read(3, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 1048576) = 2896
> ..
> 
> This is exactly what I'd expect if the machine is *not* under excessive 
> load.

That's fine, but why is it that my trivial program can't do as well as 
dd | rsh dd?

A short summary is "can someone please post a test program that sources
and sinks data at the wire speed?"  because apparently I'm too old and
clueless to write such a thing.
-- 
---
Larry McVoy                lm at bitmover.com           http://www.bitkeeper.com
