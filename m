From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.23-rc4-mm1: unpingable box and NULL dereference at
 tcp_rto_min()
Date: Sun, 2 Sep 2007 13:52:45 -0700
Message-ID: <20070902135245.aed7c7a9.akpm@linux-foundation.org>
References: <20070831215822.26e1432b.akpm@linux-foundation.org>
	<20070902023618.GA2537@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759061AbXIBUxJ@vger.kernel.org>
In-Reply-To: <20070902023618.GA2537@martell.zuzino.mipt.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> On Sun, 2 Sep 2007 06:36:19 +0400 Alexey Dobriyan <adobriyan@gmail.com> wrote:
> On Fri, Aug 31, 2007 at 09:58:22PM -0700, Andrew Morton wrote:
> > ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.23-rc4/2.6.23-rc4-mm1/
> > - dynticks-for-x86_64 has returned
> 
> Good news is that, contary to popular belief, -mm is not horrible piece
> of crap and NO_HZ on x86_64 worked here straight away.

variable.  It at least Works For Me before it goes out.

> 
> The bad news is something knocked off box from the net, then panicked it:

Yeah, the net tree has been quite bad lately.  Unusually bad - it's usually
one of the good ones.

It also breaks a lot of the net driver work in several other trees (I dropped
git-ixgbe.patch wholesale because of this).  But there isn't a lot we can
do about that.  
