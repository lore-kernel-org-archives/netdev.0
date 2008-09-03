From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1 net-2.6] Re-enable IP when MTU > 68
Date: Tue, 02 Sep 2008 17:29:39 -0700 (PDT)
Message-ID: <20080902.172939.42163782.davem@davemloft.net>
References: <48B81457.9010105@linux.vnet.ibm.com>
	<20080829.133345.248034879.davem@davemloft.net>
	<48B989FE.9070604@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org,
	rafaello@br.ibm.com
To: leitao@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60539
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754379AbYICA3p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2008 20:29:45 -0400
In-Reply-To: <48B989FE.9070604@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Breno Leitao <leitao@linux.vnet.ibm.com>
Date: Sat, 30 Aug 2008 14:57:18 -0300

> Re-enable IP when the MTU gets back to a valid size. 
> 
> This patch just checks if the in_dev is NULL on a NETDEV_CHANGEMTU event
> and if MTU is valid (bigger than 68), then re-enable in_dev. 
> 
> Also a function that checks valid MTU size was created.
> 
> Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>

Looks good, patch applied, thanks.
