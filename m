From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25] [IPv4] Remove unused define in
 include/net/arp.h (HAVE_ARP_CREATE)
Date: Sun, 30 Dec 2007 23:23:55 -0800 (PST)
Message-ID: <20071230.232355.35684204.davem@davemloft.net>
References: <eb3ff54b0712280720r723856afi55f591e214b7ed14@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ramirose@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40646
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753122AbXLaHX4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2007 02:23:56 -0500
In-Reply-To: <eb3ff54b0712280720r723856afi55f591e214b7ed14@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Rami Rosen" <ramirose@gmail.com>
Date: Fri, 28 Dec 2007 17:20:34 +0200

> Signed-off-by: Rami Rosen <ramirose@gmail.com>

This was added long ago by some bonding driver infrastructure changes
so that code could check whether the arp_create() helper function
existed in the kernel.

But it is totally unused now and yes it should be removed.

Patch applied.
