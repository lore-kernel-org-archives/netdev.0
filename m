From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: sched: fix tc_should_offload for specific
 clsact classes
Date: Tue, 07 Jun 2016 17:00:07 -0700 (PDT)
Message-ID: <20160607.170007.2097162678054823317.davem@davemloft.net>
References: <6eb47dcc252d843d7338ce2c9b98f667b45c8450.1465245985.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john.fastabend@gmail.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59193 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751475AbcFHAAJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 20:00:09 -0400
In-Reply-To: <6eb47dcc252d843d7338ce2c9b98f667b45c8450.1465245985.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Mon,  6 Jun 2016 22:50:39 +0200

> When offloading classifiers such as u32 or flower to hardware, and the
> qdisc is clsact (TC_H_CLSACT), then we need to differentiate its classes,
> since not all of them handle ingress, therefore we must leave those in
> software path. Add a .tcf_cl_offload() callback, so we can generically
> handle them, tested on ixgbe.
> 
> Fixes: 10cbc6843446 ("net/sched: cls_flower: Hardware offloaded filters statistics support")
> Fixes: 5b33f48842fa ("net/flower: Introduce hardware offload support")
> Fixes: a1b7c5fd7fe9 ("net: sched: add cls_u32 offload hooks for netdevs")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied, thanks Daniel.
