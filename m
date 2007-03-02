From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: s390 allmodconfig
Date: Fri, 02 Mar 2007 18:48:03 +0100
Message-ID: <1172857683.18913.5.camel@localhost>
References: <20070302001811.b103e2b2.akpm@linux-foundation.org>
	 <20070302002512.bd9bbb80.akpm@linux-foundation.org>
	 <1172831904.3482.13.camel@johannes.berg>
	 <20070302030646.0930d263.akpm@linux-foundation.org>
	 <1172833908.3482.20.camel@johannes.berg>
Reply-To: schwidefsky@de.ibm.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Marcel Holtmann <marcel@holtmann.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	Michael Buesch <mb@bu3sch.de>,
	Richard Purdie <rpurdie@rpsys.net>, netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.uk.ibm.com ([195.212.29.136]:57663 "EHLO
	mtagate3.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2992678AbXCBRsK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Mar 2007 12:48:10 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate3.uk.ibm.com (8.13.8/8.13.8) with ESMTP id l22Hm6wI099694
	for <netdev@vger.kernel.org>; Fri, 2 Mar 2007 17:48:06 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l22Hm4gk1392688
	for <netdev@vger.kernel.org>; Fri, 2 Mar 2007 17:48:06 GMT
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l22Hm3fL026945
	for <netdev@vger.kernel.org>; Fri, 2 Mar 2007 17:48:04 GMT
In-Reply-To: <1172833908.3482.20.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-03-02 at 12:11 +0100, Johannes Berg wrote:
> On Fri, 2007-03-02 at 03:06 -0800, Andrew Morton wrote:
> > s390 is weird ;)   There's no way it'll support any of the hardware which you're
> > working on (until they release the s390 laptop).  So all we really want to
> > do here is to avoid breaking s390 allmodconfig.

Well, I would not say "weird" but different. None of the usual device
attachments is present on a s390. That includes memory mapped i/o (!).

> Alright. I think we'll probably have to make bcm43xx and b44 depend on
> SSB instead of selecting it like the LED trigger stuff below.
> 
> But I don't see why s390 can't include hw random, led trigger or even
> hid, those are all software features afaict.

True. I'm still sitting on a couple of patches that make s390 use the
standard drivers/Kconfig. The downside of these patches is that I have
to add a lot of "depends on !S390" all over the place.

> > OK, I'll try that, thanks.
> 
> Not that it'll actually help get the compile through... bcm43xx will
> drop fail and bluetooth probably as well.

No bcm43xx, no bluetooth on s390..

-- 
blue skies,
  Martin.

Martin Schwidefsky
Linux for zSeries Development & Services
IBM Deutschland Entwicklung GmbH

"Reality continues to ruin my life." - Calvin.


