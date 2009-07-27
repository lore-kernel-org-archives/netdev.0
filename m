From: Todd Merritt <tmerritt@email.arizona.edu>
Subject: Re: ixgbe: panic in =?utf-8?b?aXhnYmVfY2xlYW5fcnhfaXJxKCk=?=
Date: Mon, 27 Jul 2009 21:50:31 +0000 (UTC)
Message-ID: <loom.20090727T214746-75@post.gmane.org>
References: <1248266678.17215.15.camel@localhost.localdomain>  <Pine.WNT.4.64.0907221110550.9360@ppwaskie-MOBL2.amr.corp.intel.com>  <1248338779.17215.23.camel@localhost.localdomain>  <1248362493.17215.45.camel@localhost.localdomain> <1248424910.17215.54.camel@localhost.localdomain> <Pine.WNT.4.64.0907241142370.2084@ppwaskie-MOBL2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:43667 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751634AbZG0VzE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jul 2009 17:55:04 -0400
Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1MVY9u-0001IF-My
	for netdev@vger.kernel.org; Mon, 27 Jul 2009 21:55:03 +0000
Received: from 150.135.210.16 ([150.135.210.16])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 27 Jul 2009 21:55:02 +0000
Received: from tmerritt by 150.135.210.16 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 27 Jul 2009 21:55:02 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Waskiewicz Jr, Peter P <peter.p.waskiewicz.jr <at> intel.com> writes:

> 
> On Fri, 24 Jul 2009, Jesper Dangaard Brouer wrote:
> 
> > On Thu, 2009-07-23 at 17:21 +0200, Jesper Dangaard Brouer wrote:
> > > I'm going to run a test with a no-preempt kernel over night...
> > 
> > The no-preempt kernel has been stable for 17 hours, while running a four
> > times 10GbE pktgen load test (using 1024 bytes packets).
> > 
> > Kernel git version (git describe):
> >  v2.6.31-rc1-932-g8e321c4
> > 
> > Git ("git log e594e96..8e321c4 drivers/net/ixgbe") reports not changes
> > to the ixgbe driver between these two kernel versions.
> 
> Thanks for the additional info Jesper.  This is definately a good data 
> point.  I'm not sure where to go with the preemption debugging at this 
> point with our driver under heavy load.  We're still trying to repro here.  
> I'll keep digging around though in the meantime.
> 
> This is the second preemption-induced bug from ixgbe we've had reported in 
> a few days.  Eek!
> 
We're getting a panic in the same function with the stable version of the ixgbe
driver 2.0.38.2-1 on redhat 5 kernel-2.6.18-128.1.10.el5.  Is there a dev
release of the driver that might have a fix in it ?

Thanks,
Todd



