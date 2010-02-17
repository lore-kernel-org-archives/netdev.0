From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 3/4] be2net: fix rx-path to ignore a flush
 completion
Date: Wed, 17 Feb 2010 13:50:32 -0800 (PST)
Message-ID: <20100217.135032.78375251.davem@davemloft.net>
References: <20100217113526.GA20173@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathyap@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59763
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757548Ab0BQVuQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 16:50:16 -0500
In-Reply-To: <20100217113526.GA20173@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathyap@serverengines.com>
Date: Wed, 17 Feb 2010 17:05:26 +0530

> The flush compl (compl with numfrags == 0; no data) is rcvd
> from hw to indicate completion of RXQ destory operation. Fix
> the RX path to not process it as RX data.
> 
> Signed-off-by: Sathya Perla <sathyap@serverengines.com>
 ...
>  	if (q->created) {
>  		be_cmd_q_destroy(adapter, q, QTYPE_RXQ);
> +		

Trailing whitespace, which I fixed up.

Applied.
