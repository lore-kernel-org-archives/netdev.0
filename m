From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ep93xx_eth: Use net_device_stats from struct
 net_device
Date: Thu, 19 Aug 2010 17:19:26 -0700 (PDT)
Message-ID: <20100819.171926.241460691.davem@davemloft.net>
References: <1282061678-19590-1-git-send-email-tklauser@distanz.ch>
	<1282205434-9601-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kernel@wantstofly.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49335
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752468Ab0HTATK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 20:19:10 -0400
In-Reply-To: <1282205434-9601-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Thu, 19 Aug 2010 10:10:34 +0200

> struct net_device has its own struct net_device_stats member, so use
> this one instead of a private copy in the ep93xx_priv struct. As the new
> ndo_get_stats function would just return dev->stats we can omit it.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied.
