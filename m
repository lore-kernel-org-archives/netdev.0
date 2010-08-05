From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: Fix napi_gro_frags vs netpoll path
Date: Thu, 05 Aug 2010 13:22:07 -0700 (PDT)
Message-ID: <20100805.132207.124011019.davem@davemloft.net>
References: <20100805111911.GB19965@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	xiaohui.xin@intel.com
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47429
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934138Ab0HEUVs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Aug 2010 16:21:48 -0400
In-Reply-To: <20100805111911.GB19965@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Thu, 5 Aug 2010 11:19:11 +0000

> Slight changelog and subject fixes only, sorry.
> 
> Jarek P.
> ------------------>
> 
> The netpoll_rx_on() check in __napi_gro_receive() skips part of the
> "common" GRO_NORMAL path, especially "pull:" in dev_gro_receive(),
> where at least eth header should be copied for entirely paged skbs.
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Applied, with Herbert's ACK to v1.
