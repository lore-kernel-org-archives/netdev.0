From: Benny Amorsen <benny+usenet@amorsen.dk>
Subject: Re: [RFD] L2 Network namespace infrastructure
Date: 24 Jun 2007 12:25:50 +0200
Message-ID: <m3zm2p7ioh.fsf@ursa.amorsen.dk>
References: <20070623.135737.22037347.davem@davemloft.net> <467D9B8F.2050403@garzik.org> <m1ejk28eku.fsf@ebiederm.dsl.xmission.com> <20070623.224853.12137896.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:45267 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753762AbXFXKdz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Jun 2007 06:33:55 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1I2PPB-0000cW-Mh
	for netdev@vger.kernel.org; Sun, 24 Jun 2007 12:33:17 +0200
Received: from hd5b9080a.c45-01-12.sta.perspektivbredband.net ([213.185.8.10])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sun, 24 Jun 2007 12:33:17 +0200
Received: from benny+usenet by hd5b9080a.c45-01-12.sta.perspektivbredband.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sun, 24 Jun 2007 12:33:17 +0200
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>>>> "DM" == David Miller <davem@davemloft.net> writes:

DM> Containers are I believe a step backwards, and we're better than
DM> that.

Are there any alternative proposals?

I guess it would be a start if you could run processes with a
different policy table as default. Ideally traffic from those
processes would automatically enter a particular policy table without
having to manually set up "ip rule" to catch their traffic. ip route
would by default show that policy table; quagga would by default
manage that table.

I think that would provide me with the functionality I need, and it
would not pretend to provide isolation.


/Benny


