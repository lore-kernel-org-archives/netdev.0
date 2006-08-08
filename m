From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] yet another IPX nonlinear receive fix
Date: Tue, 08 Aug 2006 16:49:09 -0700 (PDT)
Message-ID: <20060808.164909.65821183.davem@davemloft.net>
References: <20060808161824.5727f57d@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@ghostprotocols.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:42430
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030342AbWHHXtE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 19:49:04 -0400
To: shemminger@osdl.org
In-Reply-To: <20060808161824.5727f57d@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Tue, 8 Aug 2006 16:18:24 -0700

> Need to check some more cases in IPX receive.
> If the skb is purely fragments, the IPX header needs to
> be extracted. The function pskb_may_pull() may in theory invalidate
> all the pointers in the skb, so references to ipx header must be
> refreshed.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Applied, thanks Stephen.
