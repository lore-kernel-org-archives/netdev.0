From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dev: remove duplicate 'skb->dev = dev' in
 dev_forward_skb()
Date: Fri, 17 May 2013 18:23:33 -0700 (PDT)
Message-ID: <20130517.182333.1195267149778788816.davem@davemloft.net>
References: <1368783392-21574-1-git-send-email-nicolas.dichtel@6wind.com>
	<1368797952.3301.85.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46974 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751803Ab3ERBXe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 May 2013 21:23:34 -0400
In-Reply-To: <1368797952.3301.85.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 17 May 2013 06:39:12 -0700

> On Fri, 2013-05-17 at 11:36 +0200, Nicolas Dichtel wrote:
>> This was added by commit 59b9997baba5 (Revert "net: maintain namespace
>> isolation between vlan and real device").
>> In fact, before the initial commit - the one that is reverted -, this
>> statement was not present.
>> 'skb->dev = dev' is already done in eth_type_trans(), which is call just
>> after.
>> 
>> Spotted-by: Alain Ritoux <alain.ritoux@6wind.com>
>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>> ---
> 
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied.
