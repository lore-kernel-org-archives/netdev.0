From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: eth: altera: Remove sgdmadesclen member from
 altera_tse_private
Date: Wed, 12 Aug 2015 14:31:54 -0700 (PDT)
Message-ID: <20150812.143154.71958405013636855.davem@davemloft.net>
References: <1439202392-6808-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vbridger@opensource.altera.com, netdev@vger.kernel.org,
	nios2-dev@lists.rocketboards.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60147 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750856AbbHLVbz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 17:31:55 -0400
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

No feedback from Vince about whether this was intended to be used in
some way or not, so I'm applying this to net-next, thanks Tobias.
