From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] smsc95xx: fix reset check
Date: Mon, 02 May 2011 15:51:27 -0700 (PDT)
Message-ID: <20110502.155127.102566507.davem@davemloft.net>
References: <1304188167-18152-1-git-send-email-rabin@rab.in>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steve.glendinning@smsc.com, netdev@vger.kernel.org
To: rabin@rab.in
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40733
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755221Ab1EBWwA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2011 18:52:00 -0400
In-Reply-To: <1304188167-18152-1-git-send-email-rabin@rab.in>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rabin Vincent <rabin@rab.in>
Date: Sat, 30 Apr 2011 23:59:27 +0530

> The reset loop check should check the MII_BMCR register value for
> BMCR_RESET rather than for MII_BMCR (the register address, which also
> happens to be zero).
> 
> Signed-off-by: Rabin Vincent <rabin@rab.in>

Applied, thank you.
