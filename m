From: Bodo Eggert <7eggert@gmx.de>
Subject: Re: GFP_ATOMIC page allocation failures.
Date: Sun, 6 Apr 2008 14:12:03 +0200 (CEST)
Message-ID: <alpine.LSU.0.999.0804061406380.3361@be1.lrz>
References: <adYyJ-20N-11@gated-at.bofh.it> <200804042159.54220.nickpiggin@yahoo.com.au>
 <Pine.LNX.4.58.0804041307500.9036@be10.lrz>
 <200804051206.37394.nickpiggin@yahoo.com.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: Bodo Eggert <7eggert@gmx.de>, Jeff Garzik <jeff@garzik.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Chris Snook <csnook@redhat.com>,
	Dave Jones <davej@codemonkey.org.uk>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:56658 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751402AbYDFMMt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Apr 2008 08:12:49 -0400
In-Reply-To: <200804051206.37394.nickpiggin@yahoo.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 5 Apr 2008, Nick Piggin wrote:
> On Friday 04 April 2008 22:35, Bodo Eggert wrote:
> > On Fri, 4 Apr 2008, Nick Piggin wrote:

> > > But actually developers do sometimes want see the event even if it is
> > > relatively infrequent...
> >
> > You shouldn't frighten the users either. /proc/sys/vm/debug?
> 
> Hence changing the message a to make it clear that it is not a
> problem if it is infrequent.

If it's no problem when infrequent, and if it's possible and cheap (less 
extra code than sizeof(explanation)) to not show a message if it's 
infrequent, why should the users be bothered at all? The system needs less 
than one ms to do the job, the admin needs five minutes to grep the logs.

-- 
Top 100 things you don't want the sysadmin to say:
72. My leave starts tomorrow.
