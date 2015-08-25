From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/14] RDS: Assorted bug fixes
Date: Tue, 25 Aug 2015 13:35:48 -0700 (PDT)
Message-ID: <20150825.133548.569959758046728677.davem@davemloft.net>
References: <1440283535-4800-1-git-send-email-santosh.shilimkar@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ssantosh@kernel.org
To: santosh.shilimkar@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59362 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755944AbbHYUfw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 16:35:52 -0400
In-Reply-To: <1440283535-4800-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Date: Sat, 22 Aug 2015 15:45:21 -0700

> We would like to improve RDS upstream support and in that context, I
> started playing with it.  But run into number of issues including as
> basic is RDS IB RDMA doesn't work. As part of the debug, I ended up
> creating the $subject series which has bunch of assorted fixes. At
> least with this series I can run RDS IB RDMA and other tests
> successfully.
> 
> Some of these fixes have been done by Chris Meson, Andy Grover and
> Zach Brown while at Oracle. There are still more kinks with FMR and
> error handling and I plan to address them in a follow up series.
> 
> Series generated against Linus's master(v4.2-rc-7) but also applies
> against next-next cleanly. Its tested on Oracle hardware with IB
> fabric for both bcopy as well as RDMA mode. I don't have access
> to iWARP hardware so any testing help on iWARP hardware appreciated.

Series applied to net-next, thanks.
