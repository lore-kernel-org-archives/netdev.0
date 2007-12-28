From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25] CAN: Fix plain integer definitions in
 userspace header & new CAN version 20071227
Date: Thu, 27 Dec 2007 16:49:00 -0800 (PST)
Message-ID: <20071227.164900.233018217.davem@davemloft.net>
References: <477407C1.1050405@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sam@ravnborg.org, urs@isnogud.escape.de, netdev@vger.kernel.org
To: oliver@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53274
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754214AbXL1AtB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Dec 2007 19:49:01 -0500
In-Reply-To: <477407C1.1050405@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Hartkopp <oliver@hartkopp.net>
Date: Thu, 27 Dec 2007 21:14:57 +0100

> This patch fixes the use of plain integers instead of __u32 in a struct 
> that is visible from kernel space and user space. As this change is user 
> visible this patch also updates the CAN version to 20071227.
> 
> Thanks to Sam Ravnborg for pointing out the wrong plain int usage.
> 
> It applies on the current net-2.6.25 tree.

The types are exactly the same size regardless of anything.

There is no reason to make such a big fuss about this, changing the
CAN version etc.

Also, since CAN has never shown up in a released kernel, there is
nothing to be incompatible with.

Finally, once CAN is in fact in a released kernel, you can't make
incompatible changes to the userland visible structures.  They are
going to be fixed in stone.

Therefore I'm going to check this in without all the version
changes.

Thanks.
