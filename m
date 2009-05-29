From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: dont update dev->trans_start
Date: Fri, 29 May 2009 01:47:32 -0700 (PDT)
Message-ID: <20090529.014732.107863519.davem@davemloft.net>
References: <4A1E60C9.80103@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56184
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756830AbZE2Ird (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 04:47:33 -0400
In-Reply-To: <4A1E60C9.80103@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 28 May 2009 12:00:41 +0200

> Second round of drivers for Gb cards (and NIU one I forgot in the 10GB round)
> 
> Now that core network takes care of trans_start updates, dont do it
> in drivers themselves, if possible. Drivers can avoid one cache miss
> (on dev->trans_start) in their start_xmit() handler.
> 
> Exceptions are NETIF_F_LLTX drivers
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
