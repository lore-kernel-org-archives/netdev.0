From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] arp: filter NOARP neighbours for SIOCGARP
Date: Tue, 28 Jul 2015 23:41:47 -0700 (PDT)
Message-ID: <20150728.234147.1087098759056655521.davem@davemloft.net>
References: <1437989630.20182.35.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, valas@google.com, willemb@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56520 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750957AbbG2Gls (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 02:41:48 -0400
In-Reply-To: <1437989630.20182.35.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 27 Jul 2015 11:33:50 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> When arp is off on a device, and ioctl(SIOCGARP) is queried,
> a buggy answer is given with MAC address of the device, instead
> of the mac address of the destination/gateway.
> 
> We filter out NUD_NOARP neighbours for /proc/net/arp,
> we must do the same for SIOCGARP ioctl.
> 
> Tested:
 ...
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Vytautas Valancius <valas@google.com>

Applied, thanks Eric.
