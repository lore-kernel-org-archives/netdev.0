From: David Miller <davem@davemloft.net>
Subject: Re: netconsole still hangs
Date: Wed, 12 Mar 2008 23:10:53 -0700 (PDT)
Message-ID: <20080312.231053.216645957.davem@davemloft.net>
References: <20080312161637.b082b515.akpm@linux-foundation.org>
	<20080312163013.aaf07aa0.akpm@linux-foundation.org>
	<20080312165717.c0879b1d.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org,
	rjw@sisk.pl
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46485
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750929AbYCMGKp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Mar 2008 02:10:45 -0400
In-Reply-To: <20080312165717.c0879b1d.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Wed, 12 Mar 2008 16:57:17 -0700

> I reran the test on 2.6.24 and all seemed fine: the machine didn't hang and
> stopping the script stopped the netconsole output.

Can you go back and bisect the tree in one shot to the guilty
commit you found last time, and make sure this test case
works at that point?

With the current data points available, the only conclusion
I have is that I somehow mis-reverted the changes or missed
some important detail.  Because, you said that the problem
went away when you bisected to that specific point.

Thanks.
