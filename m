From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: eth: altera: Remove sgdmadesclen member from
 altera_tse_private
Date: Mon, 10 Aug 2015 21:12:21 -0700 (PDT)
Message-ID: <20150810.211221.1678479250895439476.davem@davemloft.net>
References: <1439202392-6808-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vbridger@opensource.altera.com, netdev@vger.kernel.org,
	nios2-dev@lists.rocketboards.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46108 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750934AbbHKEMV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2015 00:12:21 -0400
In-Reply-To: <1439202392-6808-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Mon, 10 Aug 2015 12:26:32 +0200

> altera_tse_private->sgdmadesclen is always assigned assigned the same
> value and never changes during runtime.  Remove the struct member and
> use a new define for sizeof(struct sgdma_descrip) instead.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

I think the intention was to use different descriptor sizes in the future.

Vince?
