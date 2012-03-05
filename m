From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rtnetlink: fix rtnl_calcit() and rtnl_dump_ifinfo()
Date: Sun, 04 Mar 2012 22:03:13 -0500 (EST)
Message-ID: <20120304.220313.692485484611282451.davem@davemloft.net>
References: <20120221215127.30280.30853.stgit@gitlad.jf.intel.com>
	<20120221.165750.2246668899195223381.davem@davemloft.net>
	<1330900330.17266.10.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregory.v.rose@intel.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47972 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752335Ab2CEDFQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Mar 2012 22:05:16 -0500
In-Reply-To: <1330900330.17266.10.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 04 Mar 2012 14:32:10 -0800

> nlmsg_parse() might return an error, so test its return value before
> potential random memory accesses.
> 
> Errors introduced in commit 115c9b81928 (rtnetlink: Fix problem with
> buffer allocation)
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Greg Rose <gregory.v.rose@intel.com>

Applied, thanks a lot Eric.
