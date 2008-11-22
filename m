From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/5] enic: enable ethtool LRO support
Date: Fri, 21 Nov 2008 21:27:59 -0800 (PST)
Message-ID: <20081121.212759.193717204.davem@davemloft.net>
References: <20081122003219.15540.26759.stgit@palito_client100.nuovasystems.com>
	<20081122003357.15540.89885.stgit@palito_client100.nuovasystems.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: scofeldm@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54309
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750987AbYKVF2A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Nov 2008 00:28:00 -0500
In-Reply-To: <20081122003357.15540.89885.stgit@palito_client100.nuovasystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <scofeldm@cisco.com>
Date: Fri, 21 Nov 2008 16:33:57 -0800

> enic: enable ethtool LRO support
> 
> Enable ethtool support for get/set_flags so LRO can be turned on/off by fwding drivers such as the bridge driver.  LRO is not compatible with fwding drivers.
> 
> Signed-off-by: Scott Feldman <scofeldm@cisco.com>

This didn't apply properly to net-next-2.6, but I fixed that up when
adding these patches.  I absolutely will not do that next time.

Please always generate your patches against net-next-2.6 unless
they fix a regression in the official regression list since we
are now in -rc phase.

Thank you.
