From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4 net-next] tcp: undo on DSACK during recovery
Date: Thu, 30 May 2013 18:07:34 -0700 (PDT)
Message-ID: <20130530.180734.1622987677200418751.davem@davemloft.net>
References: <1369873214-29502-1-git-send-email-ycheng@google.com>
	<1369873214-29502-4-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ncardwell@google.com, edumazet@google.com, nanditad@google.com,
	aterzis@google.com, netdev@vger.kernel.org
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59815 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752424Ab3EaBHf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 21:07:35 -0400
In-Reply-To: <1369873214-29502-4-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Wed, 29 May 2013 17:20:14 -0700

> If the receiver supports DSACK, sender can detect false recoveries and
> revert cwnd reductions triggered by either severe network reordering or
> concurrent reordering and loss event.
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>

Applied.
