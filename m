From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] enic: do hang reset only in case of tx
 timeout
Date: Mon, 05 Oct 2015 03:52:06 -0700 (PDT)
Message-ID: <20151005.035206.1974162243532680339.davem@davemloft.net>
References: <1443689327-15776-1-git-send-email-_govind@gmx.com>
	<1443689327-15776-2-git-send-email-_govind@gmx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ssujith@cisco.com, benve@cisco.com
To: _govind@gmx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39033 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753192AbbJEKg0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 06:36:26 -0400
In-Reply-To: <1443689327-15776-2-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Govindarajulu Varadarajan <_govind@gmx.com>
Date: Thu,  1 Oct 2015 14:18:47 +0530

> The current code invokes hang reset in case of error interrupt. We should
> hang reset only in case of tx timeout. This because of the way hang reset
> is implemented in firmware. Hang reset takes more firmware resources than
> soft reset. Adaptor does not generate error interrupt in case of tx
> timeout.
> 
> Hang reset only in case of tx timeout, in .ndo_tx_timeout. Do soft reset
> otherwise. Introduce deferred work, enic_tx_hang_reset, to do hang reset.
> 
> Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>

Applied.
