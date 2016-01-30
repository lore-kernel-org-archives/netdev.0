From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] irda: fix a potential use-after-free in
 ircomm_param_request
Date: Fri, 29 Jan 2016 22:59:40 -0800 (PST)
Message-ID: <20160129.225940.898285362491527760.davem@davemloft.net>
References: <1454097483-29308-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dvyukov@google.com, samuel@sortiz.org
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42935 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752062AbcA3G7l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jan 2016 01:59:41 -0500
In-Reply-To: <1454097483-29308-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Fri, 29 Jan 2016 11:58:03 -0800

> self->ctrl_skb is protected by self->spinlock, we should not
> access it out of the lock. Move the debugging printk inside.
> 
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Cc: Samuel Ortiz <samuel@sortiz.org>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied, thanks.
