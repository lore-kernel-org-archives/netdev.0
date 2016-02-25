From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] qed*: Driver updates
Date: Thu, 25 Feb 2016 16:55:48 -0500 (EST)
Message-ID: <20160225.165548.805464579975888744.davem@davemloft.net>
References: <1456325570-1514-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46597 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750717AbcBYVzw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 16:55:52 -0500
In-Reply-To: <1456325570-1514-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Wed, 24 Feb 2016 16:52:44 +0200

> Usually I try to provide a sensible description of the patch set even if
> it lacks a general 'motif', but this simply contains several small,
> unrelated and self-explenatory tweaks and additions.

Series applied, however....

I really wonder about how you stop and start the TX queues on carrier status
change.

The qdisc layer does that for you already, and prevents any TX from occuring
when the carrier is off.

So please explore removing that seemingly needless code.

Thanks.
