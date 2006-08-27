From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/7] [DCCP]: Fixes and enhancements
Date: Sat, 26 Aug 2006 19:08:51 -0700 (PDT)
Message-ID: <20060826.190851.74747699.davem@davemloft.net>
References: <200608241516.34448.ian.mcdonald@jandi.co.nz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: a.bittau@cs.ucl.ac.uk, arnaldo.melo@gmail.com,
	dccp@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:32478
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750997AbWH0CIz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 Aug 2006 22:08:55 -0400
To: ian.mcdonald@jandi.co.nz
In-Reply-To: <200608241516.34448.ian.mcdonald@jandi.co.nz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date: Thu, 24 Aug 2006 15:16:33 +1200

> Please find following a series of patches for DCCP.
> 
> These have been tested against torvalds/linux-2.6.git and davem/net-2.6.19.git
> 
> My opinion is that 1 and 2 can go straight into 2.6.18 as documentation
> changes only - Dave - are you able to do as Arnaldo is very busy at present.
> 
> I would love 3, 4, 5 to go into 2.6.18 as these resolve long standing CCID3
> issues that have been in the DCCP tree since inception and have caught a
> number of people.

Ok, I'll toss 1-5 into 2.6.18

One thing I don't understand is this description from patch 5:

--------------------
This gives a theoretical speed of 71.9 Kbits/s. I measured across three
runs with this patch set and got 70.1 Kbits/s. Without this patchset the
average was 232 Kbits/s which means Linux can't be used for CCID3 research
properly.
--------------------

Decreasing the transfer rate is desirable?  I read this as saying
this "fix" drops the transfer rate down from 232Kb/sec to
70.1Kb/sec.  What's going on here?
