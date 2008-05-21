From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/10] Stir up struct net_device_stats usage
 and whereabouts.
Date: Wed, 21 May 2008 14:18:11 -0700 (PDT)
Message-ID: <20080521.141811.142069091.davem@davemloft.net>
References: <4832FBD7.7040209@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41107
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752300AbYEUVSP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2008 17:18:15 -0400
In-Reply-To: <4832FBD7.7040209@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 20 May 2008 20:27:03 +0400

> There is a on-device statistics already, so those drivers, that
> needs some statistics, may use this one. This set relaxes bridge, 
> tunnels and mr devices thus, making them occupy less memory.
> 
> Besides, the get_stats pointer and the pointer it returns are no
> longer NULL, while there are still some places, that check for this.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

All applied, thanks Pavel.

I'll push these out to net-next-2.6 after some build tests.
