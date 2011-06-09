From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 00/12][pull request] Intel Wired LAN Driver Update
Date: Thu, 09 Jun 2011 00:58:21 -0700 (PDT)
Message-ID: <20110609.005821.841607202181194646.davem@davemloft.net>
References: <1307605611.32044.16.camel@jtkirshe-mobl>
	<20110609.005051.1530473933808285841.davem@davemloft.net>
	<1307605995.32044.18.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60309 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753366Ab1FIH6Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2011 03:58:25 -0400
In-Reply-To: <1307605995.32044.18.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 09 Jun 2011 00:53:14 -0700

> Just did, I saw that I did not have enabled and I got the same issue.  I
> am looking into now, and will check to make sure there were no other
> netlink_dump_start() references missed as well.

Ummm, you're not doing "allmodconfig" builds for validation?

I guarentee you have much more powerful computers than I do and I
do allmodconfig/allyesconfig builds across the board during my work.

And if you're touching global code, you should too :-)
