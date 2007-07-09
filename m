From: Akira Tsukamoto <akirat@rd.scei.sony.co.jp>
Subject: Re: [Cbe-oss-dev] [PATCH] ps3: gigabit ethernet driver for PS3, take3
Date: Mon, 09 Jul 2007 10:50:19 +0900
Message-ID: <20070709102243.03C0.AKIRAT@rd.scei.sony.co.jp>
References: <468D2098.50507@austin.ibm.com> <20070706180241.GB4457@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: Masakazu Mokuno <mokuno@sm.sony.co.jp>, netdev@vger.kernel.org,
	Jeff Garzik <jeff@garzik.org>, cbe-oss-dev@ozlabs.org
To: linas@austin.ibm.com (Linas Vepstas)
Return-path: <netdev-owner@vger.kernel.org>
Received: from MGW3.Sony.CO.JP ([137.153.0.15]:35760 "EHLO mgw3.sony.co.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758498AbXGICkW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Jul 2007 22:40:22 -0400
Received: from mail2.sony.co.jp (localhost [127.0.0.1])
	by mail2.sony.co.jp (R8/Sony) with ESMTP id l691oQn1008642
	for <netdev@vger.kernel.org>; Mon, 9 Jul 2007 10:50:26 +0900 (JST)
Received: from mailgw02.scei.sony.co.jp (mailgw02.scei.sony.co.jp [43.27.73.8])
	by mail2.sony.co.jp (R8/Sony) with SMTP id l691oMg6008547
	for <netdev@vger.kernel.org>; Mon, 9 Jul 2007 10:50:25 +0900 (JST)
In-Reply-To: <20070706180241.GB4457@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Fri, 6 Jul 2007 13:02:41 -0500, linas@austin.ibm.com (Linas Vepstas) mentioned: 
> of the spidernet device driver.  Please note that the old
> spidernet had absolutely disasterous performance for transmit;
> it also had a variety of crazy hangs and lockups under 
> high-stress conditions; or NFS operation, or certain back-to-back
> tcp usage scenarios. A few dozen bugfixes went in since
> the time that the gelic snapshot was taken.

I think we know the problems of old spidernet issues, we uses QS20 also 
in our lab.
Current gelic has fixed them all separated from your work and it have no 
remaining issues or performance problem.
In our measurement, PS3 network performance is better than IBM QS20 right
now.
I totally understand difficultness of your effort that fixing spidernet 
without decent documentation which we have, but the changes we made was 
significantly large as you see if you diff gelic driver with current 
spidernet driver (totally different), so the conclusion of discussion at 
3C common-linux wg (Sony, IBM and Toshiba) was to include main line 
differently first then consider unifying it later. Otherwise we won't 
able to see PS3 network stack working for long time.

Akira
-- 
Akira Tsukamoto
Sony Computer Entertainment Inc. 
Computer Development Div. Distributed OS Development Dept. 
Japan

