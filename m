From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] ethoc: Write bus addresses to registers
Date: Sun, 23 May 2010 23:17:12 -0700 (PDT)
Message-ID: <20100523.231712.165155558.davem@davemloft.net>
References: <1274161166-18521-1-git-send-email-jonas@southpole.se>
	<1274161166-18521-2-git-send-email-jonas@southpole.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jonas@southpole.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50376
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752498Ab0EXGRC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 May 2010 02:17:02 -0400
In-Reply-To: <1274161166-18521-2-git-send-email-jonas@southpole.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jonas Bonn <jonas@southpole.se>
Date: Tue, 18 May 2010 07:39:24 +0200

> The ethoc driver should be writing bus addresses to the ethoc registers, not
> virtual addresses.
> 
> Also, use bus_to_virt instead of phys_to_virt to make this explicit.

Portable drivers must not use bus_to_virt().

You should keep track of the virtual addresses of the mapped RX
packets in your RX ring datastructure.
