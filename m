From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vlan: allow VLAN ID 0 to be used
Date: Mon, 26 Oct 2009 18:41:20 -0700 (PDT)
Message-ID: <20091026.184120.255143588.davem@davemloft.net>
References: <4AE5CAC6.4000604@gmail.com>
	<20091026.173232.33817336.davem@davemloft.net>
	<4AE64E41.5030607@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: benny+usenet@amorsen.dk, gertjan_hofman@yahoo.com,
	mcarlson@broadcom.com, netdev@vger.kernel.org, kaber@trash.net
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60172
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753497AbZJ0Bk4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2009 21:40:56 -0400
In-Reply-To: <4AE64E41.5030607@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 27 Oct 2009 02:34:57 +0100

> I hope I did not miss another important thing in this second version.
> 
> Again, tested on tg3 only, and on net-next-2.6 tree
> 
> [PATCH] vlan: allow null VLAN ID to be used

Looks good, applied to net-next-2.6

Someone now needs to convert IXGBE to use VLAN_PRIO_MASK and
VLAN_PRIO_SHIFT instead of it's internal macros.
