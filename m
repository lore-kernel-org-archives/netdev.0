From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/7] bna: Update driver version to 3.0.23.0 (resubmit)
Date: Wed, 04 Apr 2012 20:15:45 -0400 (EDT)
Message-ID: <20120404.201545.244323096520849467.davem@davemloft.net>
References: <1333554102-21973-1-git-send-email-huangj@brocade.com>
	<20120404.182105.1576892492865932011.davem@davemloft.net>
	<E5313AF6F2BFD14293E5FD0F94750F86B3A74DEE55@HQ1-EXCH01.corp.brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, AdapterLinuxOpenSrcExtTeam@Brocade.COM
To: huangj@Brocade.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51250 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754044Ab2DEARU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2012 20:17:20 -0400
In-Reply-To: <E5313AF6F2BFD14293E5FD0F94750F86B3A74DEE55@HQ1-EXCH01.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jing Huang <huangj@Brocade.COM>
Date: Wed, 4 Apr 2012 16:07:22 -0700

> The ioc init semaphore register is only used by driver. Firmware
> will never touch this register.  It will only be set to 1 when there
> is a driver instance holding it. So in practice, the infinite look
> will happen only if a driver instance grab the semaphore but forgot
> to release it. We add this logic to serialize register access for
> potential case of concurrent PCI function probe, which seems pretty
> rare in Linux.

Thanks for the clarification.

> I agree that this code looks ugly and wrong in theory. We will consider remove it or
> implement some timeout logic for it.

Ok, great.
