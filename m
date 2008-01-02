From: Benny Amorsen <benny+usenet@amorsen.dk>
Subject: Re: [PATCH] Re: Nested VLAN causes recursive locking error
Date: Wed, 02 Jan 2008 17:40:56 +0100
Message-ID: <m3r6h0dvtz.fsf@ursa.amorsen.dk>
References: <476851DB.5080107@redhat.com> <20071220135253.GA10932@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:49819 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753842AbYABQlI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jan 2008 11:41:08 -0500
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1JA6eQ-0007jD-Ae
	for netdev@vger.kernel.org; Wed, 02 Jan 2008 16:41:06 +0000
Received: from hd5b9080a.c45-01-12.sta.perspektivbredband.net ([213.185.8.10])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 02 Jan 2008 16:41:06 +0000
Received: from benny+usenet by hd5b9080a.c45-01-12.sta.perspektivbredband.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 02 Jan 2008 16:41:06 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski <jarkao2@gmail.com> writes:

> Subject: [PATCH] nested VLAN: fix lockdep's recursive locking warning
>
> Allow vlans nesting other vlans without lockdep's warnings (max. 8 levels).
>
> Reported-by: Benny Amorsen
> Tested-by: Benny Amorsen	(?) NEEDS TESTING!
>
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

The box that shows the problem is "almost-production", so it doesn't
have a build system. Is there a chance you could get the patch into
Rawhide or some other testing repository? It takes forever and a lot
of disk space to rebuild a kernel RPM, so if I could get someone else
to do the hard work, that would be lovely...

If not, I'll probably find the time to do the RPM rebuild sometime
within the next week or so.


/Benny


