From: "Giampaolo Tomassoni" <Giampaolo@Tomassoni.biz>
Subject: R: 2.6.20 and multipath routing
Date: Fri, 11 May 2007 00:49:39 +0200
Message-ID: <004201c79355$7e65ea20$7b31be60$@biz>
References: <003d01c79349$60da1870$228e4950$@biz> <46439FB8.8000502@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out3.libero.it ([212.52.84.43]:43634 "EHLO
	smtp-out3.libero.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754722AbXEJWtI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 18:49:08 -0400
Received: from localhost (172.31.0.49) by smtp-out3.libero.it (7.3.120)
        id 4611FE5E025460D1 for netdev@vger.kernel.org; Fri, 11 May 2007 00:49:07 +0200
Received: from smtp-out4.libero.it ([172.31.0.40])
	by localhost (asav-out8.libero.it [192.168.32.36]) (amavisd-new, port 10024)
	with ESMTP id Yn1NUIUjkgmz for <netdev@vger.kernel.org>;
	Fri, 11 May 2007 00:49:07 +0200 (CEST)
Received: from famiglio (151.72.93.43) by smtp-out4.libero.it (7.3.120)
        id 4611FEBC034AD4A4 for netdev@vger.kernel.org; Fri, 11 May 2007 00:49:07 +0200
In-Reply-To: <46439FB8.8000502@redhat.com>
Content-Language: it
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Messaggio originale-----
> Da: Chuck Ebbert [mailto:cebbert@redhat.com]
> 
> Giampaolo Tomassoni wrote:
> >
> > 		default  src 1.2.1.6
> > 		        nexthop via 1.2.2.254  dev atm0 weight 1
> > 		        nexthop via 1.1.2.254  dev atm1 weight 1
> >
> 
> When I tried this I found that weight 1 didn't work -- all traffic
> went out one interface until I changed both weights to 50.

I experienced the same until I discovered that I actually had to "modprobe"
multipath_rr first: Nothing did tell me that the mpath algorithm I specified
wasn't available...


> And on ethernet, I had to have static ARP entries or the kernel
> would ARP on one interface, and if it didn't get a reply in less
> than one microsecond it would immediately go to the second
> interface.

Sorry, but I didn't try this over ethernet. I can't help here.

Giampaolo

