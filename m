From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] act_pedit: check binding before calling
 tcf_hash_release()
Date: Fri, 31 Jul 2015 15:23:47 -0700 (PDT)
Message-ID: <20150731.152347.1573896616015679961.davem@davemloft.net>
References: <1438301541-26192-1-git-send-email-xiyou.wangcong@gmail.com>
	<1438301541-26192-2-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, daniel@iogearbox.net,
	cwang@twopensource.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51529 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751449AbbGaWXs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 18:23:48 -0400
In-Reply-To: <1438301541-26192-2-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Thu, 30 Jul 2015 17:12:21 -0700

> When we share an action within a filter, the bind refcnt
> should increase, therefore we should not call tcf_hash_release().
> 
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> Signed-off-by: Cong Wang <cwang@twopensource.com>

Applied.
