From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4] ether3: Use net_device_stats from struct net_device
Date: Thu, 19 Aug 2010 00:13:03 -0700 (PDT)
Message-ID: <20100819.001303.235703853.davem@davemloft.net>
References: <1282061733-19700-1-git-send-email-tklauser@distanz.ch>
	<1282198531-4157-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux@arm.linux.org.uk, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	kernel-janitors@vger.kernel.org, shemminger@vyatta.com,
	eric.dumazet@gmail.com, error27@gmail.com
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43404
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751315Ab0HSHMn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 03:12:43 -0400
In-Reply-To: <1282198531-4157-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Thu, 19 Aug 2010 08:15:31 +0200

> struct net_device has its own struct net_device_stats member, so use
> this one instead of a private copy in the ether1_priv struct. As the new
> ndo_get_stats function would just return dev->stats we can omit it. This
> patch also removes an incorrect memset of the stats on open.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
> ---

Applied, thanks.
