From: Semen Slepov <slepovss@gmail.com>
Subject: Re: /proc/net/sockstat invalid memory accounting or memory leak in latest kernels?
Date: Tue, 23 Sep 2014 20:14:31 +0000 (UTC)
Message-ID: <loom.20140923T221015-507@post.gmane.org>
References: <40bc2b5fcda47d790f1fd247bc409041@visp.net.lb>  <1405597918.10255.76.camel@edumazet-glaptop2.roam.corp.google.com>  <37e25a5815a18a2da507a5b20b58427d@visp.net.lb>  <1405604568.10255.80.camel@edumazet-glaptop2.roam.corp.google.com>  <a927787503c2f0d71c330b879303b14f@visp.net.lb> <1405672897.10255.95.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:52650 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753090AbaIWUUG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Sep 2014 16:20:06 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1XWWZ9-0002zG-VR
	for netdev@vger.kernel.org; Tue, 23 Sep 2014 22:20:04 +0200
Received: from broadband-178-140-15-18.nationalcablenetworks.ru ([178.140.15.18])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 23 Sep 2014 22:20:03 +0200
Received: from slepovss by broadband-178-140-15-18.nationalcablenetworks.ru with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 23 Sep 2014 22:20:03 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet <at> gmail.com> writes:

> 
> 
> tcp believes its under pressure because of some bug on accounting.
> 
> If you change /proc/sys/net/ipv4/tcp_mem   (3rd value), it might say it
> is not under pressure.
> 
> I am taking a look, thanks again for the report.
> 
> 

Still have this accounting bug on 3.15.7 . Is there fix in further kernel
releases (or patch)?
