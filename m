From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] netlink: Fix skb ref counting.
Date: Tue, 30 Apr 2013 15:47:06 -0400 (EDT)
Message-ID: <20130430.154706.1013690460503258249.davem@davemloft.net>
References: <1367304721-9213-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52649 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932708Ab3D3TrI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Apr 2013 15:47:08 -0400
In-Reply-To: <1367304721-9213-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Mon, 29 Apr 2013 23:52:01 -0700

> Commit f9c2288837ba072b21dba955f04a4c97eaa77b1e (netlink:
> implement memory mapped recvmsg) increamented skb->users
> ref count twice for a dump op which does not look right.
> 
> Following patch fixes that.
> 
> CC: Patrick McHardy <kaber@trash.net>
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Patrick, please review this, thanks.
