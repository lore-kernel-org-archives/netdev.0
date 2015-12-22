From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] addrconf: always initialize sysctl table data
Date: Tue, 22 Dec 2015 17:01:49 -0500 (EST)
Message-ID: <20151222.170149.2101447692486311284.davem@davemloft.net>
References: <1450724145-4777-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sasha.levin@oracle.com,
	hannes@stressinduktion.org
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55817 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753687AbbLVWBu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2015 17:01:50 -0500
In-Reply-To: <1450724145-4777-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Mon, 21 Dec 2015 10:55:45 -0800

> When sysctl performs restrict writes, it allows to write from
> a middle position of a sysctl file, which requires us to initialize
> the table data before calling proc_dostring() for the write case.
> 
> Fixes: 3d1bec99320d ("ipv6: introduce secret_stable to ipv6_devconf")
> Reported-by: Sasha Levin <sasha.levin@oracle.com>
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Tested-by: Sasha Levin <sasha.levin@oracle.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied and queued up for -stable, thanks.
