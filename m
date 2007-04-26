From: Chris Wright <chrisw@sous-sol.org>
Subject: Re: [Security] [PATCH] infinite recursion in netlink
Date: Wed, 25 Apr 2007 22:37:35 -0700
Message-ID: <20070426053735.GC2819@sequoia.sous-sol.org>
References: <20070425183856.GA6028@ms2.inr.ac.ru> <alpine.LFD.0.98.0704251311270.9964@woody.linux-foundation.org> <20070426052912.GA17402@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, security@kernel.org,
	davem@davemloft.net, jaco@kroon.co.za, netdev@vger.kernel.org
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 216-99-217-87.dsl.aracnet.com ([216.99.217.87]:47435 "EHLO
	sous-sol.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754732AbXDZFkL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Apr 2007 01:40:11 -0400
Content-Disposition: inline
In-Reply-To: <20070426052912.GA17402@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Greg KH (greg@kroah.com) wrote:
> On Wed, Apr 25, 2007 at 01:15:12PM -0700, Linus Torvalds wrote:
> > 
> > 
> > On Wed, 25 Apr 2007, Alexey Kuznetsov wrote:
> > > 
> > > Reply to NETLINK_FIB_LOOKUP messages were misrouted back to kernel,
> > > which resulted in infinite recursion and stack overflow.
> 
> Wait, I just had the bright idea of actually testing this before I
> pushed out a 2.6.20.9 kernel with another fix in it, and nope, still
> crashes, even with this patch  :(

Odd, I tested it too (on linus-git), and it's fixed (it was definitely
the problem, of sending back to kernel).

thanks,
-chris
