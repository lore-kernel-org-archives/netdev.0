From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: prevent fib6_run_gc() contention
Date: Wed, 31 Jul 2013 16:43:59 -0700 (PDT)
Message-ID: <20130731.164359.1755929233848719288.davem@davemloft.net>
References: <20130611204912.GA1255@lion.mk-sys.cz>
	<20130611.142229.497972115797274443.davem@davemloft.net>
	<20130731221931.GA27754@lion.mk-sys.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, eric.dumazet@gmail.com
To: mkubecek@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35561 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750808Ab3GaXoC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 19:44:02 -0400
In-Reply-To: <20130731221931.GA27754@lion.mk-sys.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Kubecek <mkubecek@suse.cz>
Date: Thu, 1 Aug 2013 00:19:31 +0200

> I received the feedback today. The customer reported the patch moving
> update of ip6_rt_last_gc into fib6_run_gc() before the call of
> fib6_clean_all() was not sufficient to prevent the contention with their
> workload.
> 
> So I suggest to return back to the approach I submitted originally but
> to move the update into fib6_run_gc() anyway so that every run of the
> garbage collector updates it. I will submit the patches tomorrow.

Fair enough.
