From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] forcedeth: Account for consumed budget in napi poll
Date: Thu, 06 May 2010 00:14:19 -0700 (PDT)
Message-ID: <20100506.001419.232749715.davem@davemloft.net>
References: <alpine.DEB.1.00.1005052111440.31888@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59533
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753097Ab0EFHOM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 03:14:12 -0400
In-Reply-To: <alpine.DEB.1.00.1005052111440.31888@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Wed, 5 May 2010 21:15:21 -0700 (PDT)

> Repeated calls to nv_rx_process in napi poll routine do not take
> portion of budget that has been consumed in previous calls.  Fix by
> subtracting the number of packets processed.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>

Applied.
