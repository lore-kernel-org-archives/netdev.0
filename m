From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: fix premature termination of FIN_WAIT2 time-wait
 sockets
Date: Sat, 29 Aug 2009 00:00:58 -0700 (PDT)
Message-ID: <20090829.000058.92245218.davem@davemloft.net>
References: <200908150339.12730.opurdila@ixiacom.com>
	<200908242347.05367.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: opurdila@ixiacom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33575
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751083AbZH2HAo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Aug 2009 03:00:44 -0400
In-Reply-To: <200908242347.05367.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Octavian Purdila <opurdila@ixiacom.com>
Date: Mon, 24 Aug 2009 23:47:05 +0300

> On Saturday 15 August 2009 03:39:12 Octavian Purdila wrote:
> 
>> NOTE: this issue has been found, fixed and tested on an ancient 2.6.7
>> kernel. This patch is a blind port of that fix, since unfortunately there
>> is no easy way for me to reproduce the original issue with a newer kernel.
>> But the issue still seems to be there.
> 
> Update: I was able to reproduce the issue on a 2.6.30 debian kernel with the 
> attached test. It took me about 10 runs of 2-5 mins each to reproduce it 
> (multiple runs to keep the capture file reasonable in terms of size).

Thanks a lot for fixing this bug.

I've applied your patch to net-next-2.6
