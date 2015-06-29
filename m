From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bnx2x: fix lockdep splat
Date: Sun, 28 Jun 2015 17:04:00 -0700 (PDT)
Message-ID: <20150628.170400.2002665011954929800.davem@davemloft.net>
References: <1435296749.4110.56.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Michal.Kalderon@qlogic.com,
	Yuval.Mintz@qlogic.com, Ariel.Elior@qlogic.com, decot@googlers.com,
	walken@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39297 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752684AbbF2AEB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Jun 2015 20:04:01 -0400
In-Reply-To: <1435296749.4110.56.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 26 Jun 2015 07:32:29 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Michel reported following lockdep splat
 ...
> As bnx2x_init_ptp() is only called if bp->flags contains PTP_SUPPORTED,
> we also need to guard bnx2x_stop_ptp() with same condition, otherwise
> ptp_task workqueue is not initialized and kernel barfs on
> cancel_work_sync()
> 
> Fixes: eeed018cbfa30 ("bnx2x: Add timestamping and PTP hardware clock support")
> Reported-by: Michel Lespinasse <walken@google.com> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks.
