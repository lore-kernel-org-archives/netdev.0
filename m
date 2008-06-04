From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/6] SCTP: Flush the queue only once during fast
 retransmit.
Date: Wed, 04 Jun 2008 12:39:42 -0700 (PDT)
Message-ID: <20080604.123942.128575696.davem@davemloft.net>
References: <1212603951-24932-1-git-send-email-vladislav.yasevich@hp.com>
	<1212603951-24932-6-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47522
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756640AbYFDTjn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2008 15:39:43 -0400
In-Reply-To: <1212603951-24932-6-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Wed,  4 Jun 2008 14:25:50 -0400

> When fast retransmit is triggered by a sack, we should flush
> the queue only once so that only 1 retransmit happens.  Also,
> since we could potentially have non-fast-rtx chunks on
> the retransmit queue, we need make sure any chunks eligable
> for fast retransmit are sent first during fast retransmission.
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
> Tested-by: Wei Yongjun <yjwei@cn.fujitsu.com>

Applied.
