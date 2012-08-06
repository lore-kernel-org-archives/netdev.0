From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net_sched: act: Delete estimator in error path.
Date: Mon, 06 Aug 2012 13:32:36 -0700 (PDT)
Message-ID: <20120806.133236.1056798225083211523.davem@davemloft.net>
References: <20120807004548.6f9e7b6d1e566d7eead73497@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shimoda.hiroaki@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39038 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932110Ab2HFUch (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Aug 2012 16:32:37 -0400
In-Reply-To: <20120807004548.6f9e7b6d1e566d7eead73497@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Date: Tue, 7 Aug 2012 00:45:48 +0900

> Some action modules free struct tcf_common in their error path
> while estimator is still active. This results in est_timer()
> dereference freed memory.
> Add gen_kill_estimator() in ipt, pedit and simple action.
> 
> Signed-off-by: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>

Applied.
