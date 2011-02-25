From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] skge: don't mark carrier down at start
Date: Thu, 24 Feb 2011 22:17:18 -0800 (PST)
Message-ID: <20110224.221718.71124618.davem@davemloft.net>
References: <20110223162156.17ab2bc5.akpm@linux-foundation.org>
	<20110223164449.2a5206b8@nehalam>
	<20110223165243.8a536913.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, gbillios@gmail.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57646
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753945Ab1BYGQl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Feb 2011 01:16:41 -0500
In-Reply-To: <20110223165243.8a536913.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Wed, 23 Feb 2011 16:52:43 -0800

> From: Stephen Hemminger <shemminger@linux-foundation.org>
> 
> The API for network devices has changed so that setting carrier off at
> probe is no longer required.  This should fix the IPv6 addrconf issue.
> 
> Addresses https://bugzilla.kernel.org/show_bug.cgi?id=29612
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> Reported-by: George Billios <gbillios@gmail.com>
> Cc: David Miller <davem@davemloft.net>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied, thanks.
