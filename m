From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH resend net] sch_tbf: use do_div() for 64-bit divide
Date: Wed, 11 Dec 2013 22:54:04 -0500 (EST)
Message-ID: <20131211.225404.2106014728866445709.davem@davemloft.net>
References: <1386814923-56180-1-git-send-email-yangyingliang@huawei.com>
	<52A92612.5080401@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fengguang.wu@intel.com, kbuild-all@01.org
To: yangyingliang@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33492 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751339Ab3LLDyJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 22:54:09 -0500
In-Reply-To: <52A92612.5080401@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yang Yingliang <yangyingliang@huawei.com>
Date: Thu, 12 Dec 2013 10:57:22 +0800

> It's doing a 64-bit divide which is not supported
> on 32-bit architectures in psched_ns_t2l(). The
> correct way to do this is to use do_div().
> 
> It's introduced by commit cc106e441a63
> ("net: sched: tbf: fix the calculation of max_size")
> 
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>

Applied, thanks.
