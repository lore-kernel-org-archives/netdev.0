From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] act_mirred: avoid calling tcf_hash_release() when
 binding
Date: Mon, 03 Aug 2015 14:13:40 -0700 (PDT)
Message-ID: <20150803.141340.660093362814455413.davem@davemloft.net>
References: <1438301541-26192-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, daniel@iogearbox.net,
	cwang@twopensource.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44885 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932358AbbHCVNl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2015 17:13:41 -0400
In-Reply-To: <1438301541-26192-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Thu, 30 Jul 2015 17:12:20 -0700

> When we share an action within a filter, the bind refcnt
> should increase, therefore we should not call tcf_hash_release().
> 
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> Signed-off-by: Cong Wang <cwang@twopensource.com>

Applied, thanks.
