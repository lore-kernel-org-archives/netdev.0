From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/11] drivers/net/hamradio: Move a dereference below a
 NULL test
Date: Tue, 16 Dec 2008 15:43:43 -0800 (PST)
Message-ID: <20081216.154343.142632693.davem@davemloft.net>
References: <Pine.LNX.4.64.0812161613320.20444@pc-004.diku.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: julia@diku.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35306
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756479AbYLPXnl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2008 18:43:41 -0500
In-Reply-To: <Pine.LNX.4.64.0812161613320.20444@pc-004.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>
Date: Tue, 16 Dec 2008 16:13:50 +0100 (CET)

> In each case, if the NULL test is necessary, then the dereference should be
> moved below the NULL test.
> 
> The semantic patch that makes this change is as follows:
 ...
> Signed-off-by: Julia Lawall <julia@diku.dk>

Applied to net-next-2.6

