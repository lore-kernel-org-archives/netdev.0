From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 1/2] genl: Allow concurrent genl callbacks.
Date: Thu, 25 Apr 2013 01:43:29 -0400 (EDT)
Message-ID: <20130425.014329.1226803564300179546.davem@davemloft.net>
References: <1366739310-18146-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dev@openvswitch.org, jesse@nicira.com
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48345 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751308Ab3DYFna (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 01:43:30 -0400
In-Reply-To: <1366739310-18146-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Tue, 23 Apr 2013 10:48:30 -0700

> All genl callbacks are serialized by genl-mutex. This can become
> bottleneck in multi threaded case.
> Following patch adds an parameter to genl_family so that a
> particular family can get concurrent netlink callback without
> genl_lock held.
> New rw-sem is used to protect genl callback from genl family unregister.
> in case of parallel_ops genl-family read-lock is taken for callbacks and
> write lock is taken for register or unregistration for any family.
> In case of locked genl family semaphore and gel-mutex is locked for
> any openration.
> 
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Applied.
