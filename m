From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: fix the bug of address check
Date: Mon, 17 May 2010 22:27:41 -0700 (PDT)
Message-ID: <20100517.222741.108775428.davem@davemloft.net>
References: <20100517103134.06160257@nehalam>
	<4BF1E45D.5000409@cn.fujitsu.com>
	<20100517180221.3a90ffcf@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shanwei@cn.fujitsu.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52036
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754579Ab0ERF1c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 01:27:32 -0400
In-Reply-To: <20100517180221.3a90ffcf@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 17 May 2010 18:02:21 -0700

> The duplicate address check code got broken in the conversion
> to hlist (2.6.35).  The earlier patch did not fix the case where
> two addresses match same hash value. Use two exit paths,
> rather than depending on state of loop variables (from macro).
> 
> Based on earlier fix by Shan Wei.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> Reviewed-by: Shan Wei <shanwei@cn.fujitsu.com>

Applied, thanks everyone.
