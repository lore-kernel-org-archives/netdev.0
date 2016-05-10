From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] fjes: Fix unnecessary spinlock_irqsave
Date: Mon, 09 May 2016 22:06:17 -0400 (EDT)
Message-ID: <20160509.220617.839239263740187736.davem@davemloft.net>
References: <1462843729-32414-1-git-send-email-izumi.taku@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, isimatu.yasuaki@jp.fujitsu.com
To: izumi.taku@jp.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36108 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753115AbcEJCGY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2016 22:06:24 -0400
In-Reply-To: <1462843729-32414-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Date: Tue, 10 May 2016 10:28:49 +0900

> commit-bd5a256 introduces a deadlock bug in fjes_change_mtu().
> This spin_lock_irqsave() is obviously unnecessary.
> 
> This patch eliminates unnecessary spin_lock_irqsave() in
> fjes_change_mtu()
> 
> Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>

Applied, thanks.
