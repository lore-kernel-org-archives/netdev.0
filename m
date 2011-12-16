From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tg3: Make the RSS indir tbl admin configurable
Date: Fri, 16 Dec 2011 01:12:11 -0500 (EST)
Message-ID: <20111216.011211.448655043846843883.davem@davemloft.net>
References: <1323996466-8139-1-git-send-email-mcarlson@broadcom.com>
	<1324004674.2825.226.camel@deadeye>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mcarlson@broadcom.com, netdev@vger.kernel.org, mchan@broadcom.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47649 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751189Ab1LPGMP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 01:12:15 -0500
In-Reply-To: <1324004674.2825.226.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 16 Dec 2011 03:04:34 +0000

> On Thu, 2011-12-15 at 16:47 -0800, Matt Carlson wrote:
>> This patch adds the ethtool callbacks necessary to change the rss
>> indirection table from userspace.  When setting the indirection table
>> through set_rxfh_indir, an indirection table size of zero is
>> interpreted to mean that the admin wants to relinquish control of the
>> table to the driver.  Should the number of interrupts change (e.g.
>> across a close / open call, or through a reset), any indirection table
>> values that exceed the number of RSS queues or interrupt vectors will
>> be automatically scaled back to values within range.
>> 
>> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
>> Signed-off-by: Michael Chan <mchan@broadcom.com>
>> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> 
> No I didn't!

Matt, really, don't do crap like this.  It's extremely rude and
completely unprofessional.
