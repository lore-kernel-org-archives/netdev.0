From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Multiple TX queue implementation and Batching
Date: Thu, 19 Jun 2008 13:17:53 +0530
Message-ID: <OF50454112.AA19F7EA-ON6525746D.002A115D-6525746D.002AD61A@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp02.in.ibm.com ([59.145.155.2]:40016 "EHLO
	e28esmtp02.in.ibm.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751582AbYFSHtb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2008 03:49:31 -0400
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28esmtp02.in.ibm.com (8.13.1/8.13.1) with ESMTP id m5J7n7mM019716
	for <netdev@vger.kernel.org>; Thu, 19 Jun 2008 13:19:07 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5J7mBDA618512
	for <netdev@vger.kernel.org>; Thu, 19 Jun 2008 13:18:14 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id m5J7n4Ds022612
	for <netdev@vger.kernel.org>; Thu, 19 Jun 2008 13:19:04 +0530
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi Dave,

Would it be possible to get a sneak preview of your multiple tx queue
implementation (along with a complete re-write of the entire tx path)?

I would like to see if batching would make sense with the new design,
or becomes redundant (or something to be done entirely at the drivers).

Thanks,

- KK

