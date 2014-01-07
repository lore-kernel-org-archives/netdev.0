From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: pcpu_tstats.syncp should be initialised in
 ip6_vti.c
Date: Tue, 07 Jan 2014 14:15:20 -0500 (EST)
Message-ID: <20140107.141520.487944276245801094.davem@davemloft.net>
References: <20140105022017.GB16180@localhost>
	<1389080383-25655-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fengguang.wu@intel.com
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43869 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751315AbaAGTPW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 14:15:22 -0500
In-Reply-To: <1389080383-25655-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Tue,  7 Jan 2014 15:39:43 +0800

> From: Li RongQing <roy.qing.li@gmail.com>
> 
> initialise pcpu_tstats.syncp to kill the calltrace
 ...
> Before 469bdcefdc ("ipv6: fix the use of pcpu_tstats in ip6_vti.c"),
> the pcpu_tstats.syncp is not used to pretect the 64bit elements of
> pcpu_tstats, so not appear this calltrace.
> 
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Applied, thanks.

It looks like ip6_tunnel.c and sit.c are OK in this area.
