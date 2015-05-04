From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bnx2x: Fix to prevent inner-reload
Date: Mon, 04 May 2015 15:55:22 -0400 (EDT)
Message-ID: <20150504.155522.854461500976391153.davem@davemloft.net>
References: <1430732052-17722-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Elior@qlogic.com
To: Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38648 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751252AbbEDTzZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 15:55:25 -0400
In-Reply-To: <1430732052-17722-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Mon, 4 May 2015 12:34:12 +0300

> Submit 909d9faae2a44 ("bnx2x: Prevent inner-reload while VFs exist")
> contained a bug - MTU change was not prevented by it; Instead, it
> `randomally' prevented bnx2x_resume() from running [harmless yet wrong].
> 
> This moves the check to its correct spot.
> 
> Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>

Applied.
