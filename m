From: David Miller <davem@davemloft.net>
Subject: Re: dynamically set number of queues for 82598 devices
Date: Tue, 03 Nov 2015 10:35:02 -0500 (EST)
Message-ID: <20151103.103502.755669061638846118.davem@davemloft.net>
References: <20151029152645.GD7657@gandi.net>
	<20151103095603.GE7714@gandi.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, talabudi@gmail.com,
	emil.s.tantilov@intel.com, jeffrey.t.kirsher@intel.com
To: william@gandi.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44577 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754762AbbKCPfG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 10:35:06 -0500
In-Reply-To: <20151103095603.GE7714@gandi.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: William Dauchy <william@gandi.net>
Date: Tue, 3 Nov 2015 10:56:03 +0100

> Hello David,
> 
> On Oct29 16:26, William Dauchy wrote:
>> I faced the problem described in commit 7e3f5c8:
>> ixgbe: fix bounds checking in ixgbe_setup_tc for 82598
>> 
>> This patch resolves an issue where users were not able to dynamically
>> set number of queues for 82598 via ethtool -L
>> 
>> I backported it for my v4.1.x build but I was wondering if this could be
>> a candidate for a backport in stable tree at least for v4.1.x.
> 
> Since we are now in a bug fix period, I was wondering if you could have
> a look at commit 7e3f5c8 (ixgbe: fix bounds checking in ixgbe_setup_tc
> for 82598)
> I don't see it in
> http://patchwork.ozlabs.org/bundle/davem/stable/?state=*
> so I was wondering if it could be a valid candidate for stable.

The Intel ethernet folks handle their driver -stable submissions.
