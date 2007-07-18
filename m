From: David Miller <davem@davemloft.net>
Subject: Re: [PPPOL2TP 1/2]: Fix use-after-free
Date: Wed, 18 Jul 2007 02:04:19 -0700 (PDT)
Message-ID: <20070718.020419.28394997.davem@davemloft.net>
References: <469CB3E1.5060901@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jchapman@katalix.com
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51343
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752614AbXGRJEU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 05:04:20 -0400
In-Reply-To: <469CB3E1.5060901@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Tue, 17 Jul 2007 14:19:45 +0200

> [PPPOL2TP]: Fix use-after-free
> 
> Don't use skb->len after passing it to ip_queue_xmit.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied.
