From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 net-next 01/10] qed: Add module with basic common
 support
Date: Sun, 11 Oct 2015 04:16:08 -0700 (PDT)
Message-ID: <20151011.041608.1224841508064967134.davem@davemloft.net>
References: <1444217127-17557-2-git-send-email-Yuval.Mintz@qlogic.com>
	<20151010.062452.1106942695684145823.davem@davemloft.net>
	<B5657A6538887040AD3A81F1008BEC63E44712@avmb3.qlogic.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Elior@qlogic.com
To: Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55203 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751102AbbJKLAR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Oct 2015 07:00:17 -0400
In-Reply-To: <B5657A6538887040AD3A81F1008BEC63E44712@avmb3.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Sat, 10 Oct 2015 14:18:18 +0000

> So far we've worked on stabalizing it on 64-bit LE endian.
> I can easily understand why we'd want to relax this restriction later on
> [and sooner rather than later], but what would you gain be gained by
> compile-fixing for platforms on which it was never tested?

This is exactly the kind of attitude I don't want to see.

I am so glad that so many driver authors supported all PCI platforms
from the very beginning so that casually I could test their driver on
my sparc64 systems.

There is huge value in expanding the compiler testing your driver
gets, from day one.
