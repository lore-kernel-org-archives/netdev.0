From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net_sched: gact: Fix potential panic in tcf_gact().
Date: Fri, 03 Aug 2012 16:47:56 -0700 (PDT)
Message-ID: <20120803.164756.840076104361757312.davem@davemloft.net>
References: <20120803195752.32410768d3d806cd241ac7a4@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shimoda.hiroaki@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41657 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753992Ab2HCXr5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Aug 2012 19:47:57 -0400
In-Reply-To: <20120803195752.32410768d3d806cd241ac7a4@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Date: Fri, 3 Aug 2012 19:57:52 +0900

> gact_rand array is accessed by gact->tcfg_ptype whose value
> is assumed to less than MAX_RAND, but any range checks are
> not performed.
> 
> So add a check in tcf_gact_init(). And in tcf_gact(), we can
> reduce a branch.
> 
> Signed-off-by: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>

Applied and queued up for -stable, thanks.
