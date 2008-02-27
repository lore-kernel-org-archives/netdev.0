From: Benny Amorsen <benny+usenet@amorsen.dk>
Subject: Re: capturing vlan on 2.6.18
Date: Wed, 27 Feb 2008 21:55:20 +0100
Message-ID: <m3r6eyyv9j.fsf@ursa.amorsen.dk>
References: <200802271517.52092.krauz@cncz.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:40001 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754193AbYB0Uzb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Feb 2008 15:55:31 -0500
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1JUTJH-0008Us-Pq
	for netdev@vger.kernel.org; Wed, 27 Feb 2008 20:55:27 +0000
Received: from hd5b9080a.c45-01-12.sta.perspektivbredband.net ([213.185.8.10])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 27 Feb 2008 20:55:27 +0000
Received: from benny+usenet by hd5b9080a.c45-01-12.sta.perspektivbredband.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 27 Feb 2008 20:55:27 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Krauz <krauz@cncz.cz> writes:

> Is this a kernel bug or am I supposed to set something?

It's an unfortunate side effect of hardware VLAN acceleration. It
can't be turned off (apart from patching the driver to not advertise
VLAN acceleration support).

Yes, it's annoying.


/Benny


