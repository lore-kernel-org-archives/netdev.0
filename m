From: Benny Amorsen <benny+usenet@amorsen.dk>
Subject: Re: e1000 performance issue in 4 simultaneous links
Date: Fri, 11 Jan 2008 12:09:32 +0100
Message-ID: <m3ir20ipoz.fsf@ursa.amorsen.dk>
References: <1199981839.8931.35.camel@cafe> <36D9DB17C6DE9E40B059440DB8D95F5204275B04@orsmsx418.amr.corp.intel.com> <20080110.172830.16409182.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:55060 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755458AbYAKLJs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jan 2008 06:09:48 -0500
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1JDHld-0006AQ-3P
	for netdev@vger.kernel.org; Fri, 11 Jan 2008 11:09:41 +0000
Received: from hd5b9080a.c45-01-12.sta.perspektivbredband.net ([213.185.8.10])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 11 Jan 2008 11:09:41 +0000
Received: from benny+usenet by hd5b9080a.c45-01-12.sta.perspektivbredband.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 11 Jan 2008 11:09:41 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> No IRQ balancing should be done at all for networking device
> interrupts, with zero exceptions.  It destroys performance.

Does irqbalanced need to be taught about this? And how about the
initial balancing, so that each network card gets assigned to one CPU?


/Benny


