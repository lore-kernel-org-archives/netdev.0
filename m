From: Benny Amorsen <benny+usenet@amorsen.dk>
Subject: Re: How I can reset TCP sockets after long suspend/resume cyscle
Date: Fri, 06 Jun 2008 10:37:12 +0200
Message-ID: <m3hcc7ufgn.fsf@ursa.amorsen.dk>
References: <200806011515.14103.maximlevitsky@gmail.com> <20080604141533.35eb6df0@extreme> <484707D9.3040900@hp.com> <200806060031.16827.maximlevitsky@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:44437 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1765043AbYFFIhY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jun 2008 04:37:24 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1K4XRo-000582-T4
	for netdev@vger.kernel.org; Fri, 06 Jun 2008 08:37:21 +0000
Received: from hd5b9080a.c45-01-12.sta.perspektivbredband.net ([213.185.8.10])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 06 Jun 2008 08:37:20 +0000
Received: from benny+usenet by hd5b9080a.c45-01-12.sta.perspektivbredband.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 06 Jun 2008 08:37:20 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Maxim Levitsky <maximlevitsky@gmail.com> writes:

> This seems the right solution,
> if this is possible, why not to check for stuck TCP connections
> on resume?

Imagine a laptop on wireless going into suspend for a few minutes,
then getting woken up. If you're lucky today, the TCP connections
survive.

If you check for stuck TCP connections right after resume, you could
have problems because the wireless hasn't negotiated encryption keys
at that point. Isn't that a concern?


/Benny


