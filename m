From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: bcmgenet: fix bcmgenet_put_tx_csum()
Date: Wed, 01 Oct 2014 22:12:11 -0400 (EDT)
Message-ID: <20141001.221211.1792251591323068470.davem@davemloft.net>
References: <20141001183001.C7D68100A08@puck.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com
To: pgynther@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39050 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751102AbaJBCMM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 22:12:12 -0400
In-Reply-To: <20141001183001.C7D68100A08@puck.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petri Gynther <pgynther@google.com>
Date: Wed,  1 Oct 2014 11:30:01 -0700 (PDT)

> bcmgenet_put_tx_csum() needs to return skb pointer back to the caller
> because it reallocates a new one in case of lack of skb headroom.
> 
> Signed-off-by: Petri Gynther <pgynther@google.com>

Applied, thank you.
