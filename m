From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] Three possible UDP fixes.
Date: Tue, 21 Jun 2011 16:31:22 -0700 (PDT)
Message-ID: <20110621.163122.2184787350829030278.davem@davemloft.net>
References: <1308689020-1873-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42625 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756939Ab1FUXbZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2011 19:31:25 -0400
In-Reply-To: <1308689020-1873-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Tue, 21 Jun 2011 16:43:37 -0400

> These were originally found on a 2.6.34 baseline, but I looked
> at them and couldn't see any reason why they wouldn't be valid
> fixes on net-next.  But I'll feel better when someone like
> Dave and/or Eric sanity checks them too.
> 
> There was one thing that was a consideration.  In the 3rd patch,
> where we clear MSG_TRUNC bit -- is there anything in there that
> we really need to be concerned about preserving on the retry,
> or could we just unconditionally do "msg->msg_flags = 0" ?
> I wasn't sure, and so sticking with clearing the offending bit
> seemed like the most cautious approach.

All applied and queued up for -stable, thanks!
