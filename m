From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fq: add fair queuing framework
Date: Mon, 25 Apr 2016 16:46:11 -0400 (EDT)
Message-ID: <20160425.164611.182072730086841196.davem@davemloft.net>
References: <1461327613-22902-1-git-send-email-michal.kazior@tieto.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, johannes@sipsolutions.net
To: michal.kazior@tieto.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33173 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933361AbcDYUqN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 16:46:13 -0400
In-Reply-To: <1461327613-22902-1-git-send-email-michal.kazior@tieto.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Kazior <michal.kazior@tieto.com>
Date: Fri, 22 Apr 2016 14:20:13 +0200

> This works on the same implementation principle as
> codel*.h, i.e. there's a generic header with
> structures and macros and a implementation header
> carrying function definitions to include in given,
> e.g. driver or module.
> 
> The fairness logic comes from
> net/sched/sch_fq_codel.c but is generalized so it
> is more flexible and easier to re-use.
> 
> Signed-off-by: Michal Kazior <michal.kazior@tieto.com>

Applied, but same caveats as for codel.
