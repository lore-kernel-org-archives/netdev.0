From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] vxlan: Fix kernel panic on device delete.
Date: Thu, 05 Sep 2013 14:51:34 -0400 (EDT)
Message-ID: <20130905.145134.5616997531517333.davem@davemloft.net>
References: <1378329141-11868-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38924 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754037Ab3IESvl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Sep 2013 14:51:41 -0400
In-Reply-To: <1378329141-11868-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Wed,  4 Sep 2013 14:12:21 -0700

> On vxlan device create if socket create fails vxlan device is not
> added to hash table. Therefore we need to check if device
> is in hashtable before we delete it from hlist.
> Following patch avoid the crash. net-next already has this fix.
 ...
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Applied.
