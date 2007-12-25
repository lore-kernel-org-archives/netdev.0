From: Benny Amorsen <benny+usenet@amorsen.dk>
Subject: Re: ipv4_devconf.arp_accept mystery
Date: Tue, 25 Dec 2007 23:08:08 +0100
Message-ID: <m3ve6mh1h3.fsf@ursa.amorsen.dk>
References: <d0383f90712230800n6e6d6b92x64eaa8dcff313915@mail.gmail.com> <E1J6mmW-0006dP-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:51001 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751235AbXLYWIk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Dec 2007 17:08:40 -0500
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1J7Hwi-0006EN-L2
	for netdev@vger.kernel.org; Tue, 25 Dec 2007 22:08:20 +0000
Received: from hd5b9080a.c45-01-12.sta.perspektivbredband.net ([213.185.8.10])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 25 Dec 2007 22:08:20 +0000
Received: from benny+usenet by hd5b9080a.c45-01-12.sta.perspektivbredband.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 25 Dec 2007 22:08:20 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu <herbert@gondor.apana.org.au> writes:

> As the name suggests you should use
>
> 	/proc/sys/net/ipv4/conf/all/arp_accept

The documentation says that if arp_accept is 0, unsolicited arp
replies are dropped. Doesn't that interfere with failover services
such as vrrp, keepalived, ucarp etc? I thought they did unsolicited
arp when failing over.


/Benny


