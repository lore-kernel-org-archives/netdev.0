From: David Miller <davem@davemloft.net>
Subject: Re: [RCU PATCH 00/14] Remove qdisc lock around ingress Qdisc
Date: Tue, 11 Mar 2014 16:36:42 -0400 (EDT)
Message-ID: <20140311.163642.197791800524216561.davem@davemloft.net>
References: <20140310170008.3011.73599.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, jhs@mojatatu.com, netdev@vger.kernel.org
To: john.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58362 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755491AbaCKUgn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 16:36:43 -0400
In-Reply-To: <20140310170008.3011.73599.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>
Date: Mon, 10 Mar 2014 10:03:22 -0700

> This series drops the qdisc lock that is currently protecting the
> ingress qdisc. This can be done after the tcf filters are made
> lockless and the statistic accounting is safe to run without locks.

This series looks great, nice work.

Please address Eric Dumazet's feedback and repost, then I'd like to
see Jamal and Cong at least give a cursory review before I apply this.

Thanks.
