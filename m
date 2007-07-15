From: David Miller <davem@davemloft.net>
Subject: Re: [NET]: Add ethtool support for NETIF_F_IPV6_CSUM devices.
Date: Sat, 14 Jul 2007 19:08:49 -0700 (PDT)
Message-ID: <20070714.190849.112849734.davem@davemloft.net>
References: <1184378602.6079.1.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52255
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751043AbXGOCIr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jul 2007 22:08:47 -0400
In-Reply-To: <1184378602.6079.1.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Fri, 13 Jul 2007 19:03:22 -0700

> [NET]: Add ethtool support for NETIF_F_IPV6_CSUM devices.
> 
> Add ethtool utility function to set or clear IPV6_CSUM feature flag.
> Modify tg3.c and bnx2.c to use this function when doing ethtool -K
> to change tx checksum.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

This is OK for now since IPV6 implies IPV4 checksumming
and this dependency is wired in elsewhere too.

If some day that implication stops existing we'll
have to revisit this code.

Applied, thanks Michael.
