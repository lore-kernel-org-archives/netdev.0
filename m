From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sb1250-mac: duplicate setting of bit
 V_MAC_RX_PL_THRSH(4) in sbmac_channel_start()
Date: Tue, 13 Oct 2009 03:48:02 -0700 (PDT)
Message-ID: <20091013.034802.90039003.davem@davemloft.net>
References: <4ACBA373.7040506@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org
To: roel.kluin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49912
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757203AbZJMKsG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2009 06:48:06 -0400
In-Reply-To: <4ACBA373.7040506@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>
Date: Tue, 06 Oct 2009 22:07:15 +0200

> The bit V_MAC_RX_PL_THRSH(4) was already set a few lines higher.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> ---
> Please review. Maybe it should be replaced by something else?

Maybe, but or'ing it in twice is definitely pointless.

Applied to net-next-2.6, thanks.
