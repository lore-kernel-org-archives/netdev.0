From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] netlink: fix null pointer dereference on nlk->groups
Date: Sun, 10 Jan 2016 23:27:07 -0500 (EST)
Message-ID: <20160110.232707.1954364745984617361.davem@davemloft.net>
References: <1452231970-27357-1-git-send-email-sploving1@gmail.com>
	<1452355001-30295-1-git-send-email-sploving1@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, netdev@vger.kernel.org
To: sploving1@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32878 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758013AbcAKE1K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jan 2016 23:27:10 -0500
In-Reply-To: <1452355001-30295-1-git-send-email-sploving1@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Baozeng Ding <sploving1@gmail.com>
Date: Sat,  9 Jan 2016 23:56:41 +0800

> If groups is not 0 and nlk->groups is NULL, it will not return
> immediately and cause a null pointer dereference later.
> 
> Signed-off-by: Baozeng Ding <sploving1@gmail.com>
> ---
> This version uses the preferred networking coding style. Thanks
> for Sergei's feedback. Also the patch keeps the original author's
> coding style as much as possible.

Is this an actual legal state?  If not, add a WARN_ON() check.

Otherwise, provide a proper OOPS log and explain how the state
can be achieved.

Thanks.
