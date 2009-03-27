From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gianfar: fix headroom expansion code
Date: Fri, 27 Mar 2009 00:38:55 -0700 (PDT)
Message-ID: <20090327.003855.197210785.davem@davemloft.net>
References: <20090325.172139.142233386.davem@davemloft.net>
	<20090326100856.265f7872@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: leoli@freescale.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43879
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754122AbZC0HjI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2009 03:39:08 -0400
In-Reply-To: <20090326100856.265f7872@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 26 Mar 2009 10:08:56 -0700

> The code that was added to increase headroom was wrong.
> It doesn't handle the case where gfar_add_fcb() changes the skb.
> Better to do check at start of transmit (outside of lock), where
> error handling is better anyway.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied, thanks Stephen.
