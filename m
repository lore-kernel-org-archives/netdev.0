From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][IRDA]: Sock leak on error path in irda_create.
Date: Tue, 03 Jun 2008 15:18:47 -0700 (PDT)
Message-ID: <20080603.151847.160365090.davem@davemloft.net>
References: <482C79D1.8000601@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, netdev@vger.kernel.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53911
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751549AbYFCWSr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 18:18:47 -0400
In-Reply-To: <482C79D1.8000601@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Thu, 15 May 2008 21:58:41 +0400

> Bad type/protocol specified result in sk leak.
> 
> Fix is simple - release the sk if bad values are given,
> but to make it possible just to call sk_free(), I move
> some sk initialization a bit lower.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied, thanks Pavel.
