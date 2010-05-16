From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xfrm: fix policy unreferencing on larval drop
Date: Sat, 15 May 2010 23:49:38 -0700 (PDT)
Message-ID: <20100515.234938.25121429.davem@davemloft.net>
References: <1273146734-8022-1-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46940
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752470Ab0EPGt3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 May 2010 02:49:29 -0400
In-Reply-To: <1273146734-8022-1-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timo Teras <timo.teras@iki.fi>
Date: Thu,  6 May 2010 14:52:14 +0300

> I mistakenly had the error path to use num_pols to decide how
> many policies we need to drop (cruft from earlier patch set
> version which did not handle socket policies right).
> 
> This is wrong since normally we do not keep explicit references
> (instead we hold reference to the cache entry which holds references
> to policies). drop_pols is set to num_pols if we are holding the
> references, so use that. Otherwise we eventually BUG_ON inside
> xfrm_policy_destroy due to premature policy deletion.
> 
> Signed-off-by: Timo Teras <timo.teras@iki.fi>

Applied, thanks a lot Timo.
