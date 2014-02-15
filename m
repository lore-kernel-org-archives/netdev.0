From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] openvswitch: rename ->sync to ->syncp
Date: Sat, 15 Feb 2014 02:06:49 -0500 (EST)
Message-ID: <20140215.020649.996515212700851070.davem@davemloft.net>
References: <1392419446-4559-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43232 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751754AbaBOHGx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Feb 2014 02:06:53 -0500
In-Reply-To: <1392419446-4559-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Fri, 14 Feb 2014 15:10:46 -0800

> Openvswitch defines u64_stats_sync as ->sync rather than ->syncp,
> so fails to compile with netdev_alloc_pcpu_stats(). So just rename it to ->syncp.
> 
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Fixes: 1c213bd24ad04f4430031 (net: introduce netdev_alloc_pcpu_stats() for drivers)
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied, thanks.
