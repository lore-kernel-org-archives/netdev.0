From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: export skb_clone_tx_timestamp
Date: Fri, 15 Apr 2011 15:46:57 -0700 (PDT)
Message-ID: <20110415.154657.179935558.davem@davemloft.net>
References: <20110414173502.GA15244@riccoc20.at.omicron.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36295
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751971Ab1DOWrc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2011 18:47:32 -0400
In-Reply-To: <20110414173502.GA15244@riccoc20.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com>
Date: Thu, 14 Apr 2011 19:35:02 +0200

> MAC drivers compiled as modules may well want to call this function via
> the skb_tx_timestamp inline function. This patch exports the function in
> order to let this happen.
> 
> Signed-off-by: Richard Cochran <richard.cochran@omicron.at>

You can submit this patch to export this variable when you also submit
a patch to a upstream driver that makes use of this interface in such
a way.

But no sooner.
