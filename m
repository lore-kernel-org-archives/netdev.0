From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bnx2x: Move statistics implementation into
 semaphores
Date: Mon, 01 Jun 2015 12:04:42 -0700 (PDT)
Message-ID: <20150601.120442.564203066952951915.davem@davemloft.net>
References: <1433160498-22539-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nikola.ciprich@linuxbox.cz,
	Ariel.Elior@qlogic.com
To: Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51914 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753212AbbFATEo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 15:04:44 -0400
In-Reply-To: <1433160498-22539-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Mon, 1 Jun 2015 15:08:18 +0300

> Commit dff173de84958 ("bnx2x: Fix statistics locking scheme") changed the
> bnx2x locking around statistics state into using a mutex - but the lock
> is being accessed via a timer which is forbidden.
> 
> [If compiled with CONFIG_DEBUG_MUTEXES, logs show a warning about
> accessing the mutex in interrupt context]
> 
> This moves the implementation into using a semaphore [with size '1']
> instead.
> 
> Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
> Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>

Applied, thank you.
