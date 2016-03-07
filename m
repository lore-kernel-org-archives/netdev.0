From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH] net: sched: fix act_ipt for LOG target
Date: Sun, 06 Mar 2016 22:58:25 -0500 (EST)
Message-ID: <20160306.225825.733343326579435375.davem@davemloft.net>
References: <1457012054-18012-1-git-send-email-psutter@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, phil@nwl.cc, jhs@mojatatu.com
To: psutter@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43022 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752239AbcCGD61 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Mar 2016 22:58:27 -0500
In-Reply-To: <1457012054-18012-1-git-send-email-psutter@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Sutter <psutter@redhat.com>
Date: Thu,  3 Mar 2016 14:34:14 +0100

> From: Phil Sutter <phil@nwl.cc>
> 
> Before calling the destroy() or target() callbacks, the family parameter
> field has to be initialized. Otherwise at least the LOG target will
> refuse to work and upon removal oops the kernel.
> 
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Phil Sutter <phil@nwl.cc>

Applied.
