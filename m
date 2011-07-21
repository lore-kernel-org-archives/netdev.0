From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 5/5] bnx2x: Broken self-test in SF mode on
 578xx
Date: Thu, 21 Jul 2011 13:01:38 -0700 (PDT)
Message-ID: <20110721.130138.1967308490914166591.davem@davemloft.net>
References: <201107212058.54522.vladz@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: vladz@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38206 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753118Ab1GUUBl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2011 16:01:41 -0400
In-Reply-To: <201107212058.54522.vladz@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Vlad Zolotarov" <vladz@broadcom.com>
Date: Thu, 21 Jul 2011 20:58:54 +0300

> This patch fixes both the failure in the self-test on 578xx
> and a hole in a parity recovery flow that this failure
> has discovered: 
>  - internal 'pending' state in a VLAN_MAC object wasn't been cleared
> when the object state change was called with DRV_ONLY flag, which in
> particular happens when a parity error happens during the self-test.
>  - bp->sp_state wasn't cleared in the similar circumstances as described 
> above.
> 
> Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied.
