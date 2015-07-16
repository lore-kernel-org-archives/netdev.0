From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: Fix finding best source address in
 ipv6_dev_get_saddr().
Date: Wed, 15 Jul 2015 21:07:24 -0700 (PDT)
Message-ID: <20150715.210724.538955221665774198.davem@davemloft.net>
References: <55A3CAFA.3060404@miraclelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ek@google.com, thehajime@gmail.com
To: hideaki.yoshifuji@miraclelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35110 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751188AbbGPEHZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2015 00:07:25 -0400
In-Reply-To: <55A3CAFA.3060404@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki/吉藤英明 <hideaki.yoshifuji@miraclelinux.com>
Date: Mon, 13 Jul 2015 23:28:10 +0900

> Commit 9131f3de2 ("ipv6: Do not iterate over all interfaces when
> finding source address on specific interface.") did not properly
> update best source address available.  Plus, it introduced
> possible NULL pointer dereference.
> 
> Bug was reported by Erik Kline <ek@google.com>.
> Based on patch proposed by Hajime Tazaki <thehajime@gmail.com>.
> 
> Fixes: 9131f3de24db4dc12199aede7d931e6703e97f3b ("ipv6: Do not
> 	iterate over all interfaces when finding source address
> 	on specific interface.")
> Signed-off-by: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>

Applied, thanks.
