From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] stmmac: dwmac-socfpga refactor+cleanup
Date: Thu, 28 Apr 2016 16:53:07 -0400 (EDT)
Message-ID: <20160428.165307.1616888254325852103.davem@davemloft.net>
References: <1461705899-17015-1-git-send-email-manabian@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: marex@denx.de, dinguyen@opensource.altera.com,
	peppe.cavallaro@st.com, alexandre.torgue@st.com,
	netdev@vger.kernel.org
To: manabian@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42150 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753066AbcD1UxJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 16:53:09 -0400
In-Reply-To: <1461705899-17015-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joachim Eastwood <manabian@gmail.com>
Date: Tue, 26 Apr 2016 23:24:54 +0200

> Couple of heads-up here:
>  1. This patch set depend on Marek's "Remove re-registration of
>     reset controller" patch [1] which is not in net-next yet.
>     Without that patch this set will not apply!
> 
>  2. The first patch changes the prototype of a couple of
>     functions used in Alexandre's "add Ethernet glue logic for
>     stm32 chip" patch [2] and will cause build failures for
>     dwmac-stm32.c if not fixed up!
>     If Alexandre's patch set is applied first I will gladly
>     rebase my patch set to account for his driver as well.
 ...
> Dave: Please let me know if you have any preferred way of
>       handling this.

You could cherry pick the patch in #1 and add it to this patch set,
in fact please respin this series that way.

For #2 it'll get sorted based upon who gets applied first.
