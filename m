From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [next-next-2.6] net: configurable device name hash
Date: Wed, 11 Nov 2009 12:42:35 -0800 (PST)
Message-ID: <20091111.124235.243348591.davem@davemloft.net>
References: <200911112116.14103.opurdila@ixiacom.com>
	<20091111.112120.134023270.davem@davemloft.net>
	<200911112138.44074.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: opurdila@ixiacom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37773
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757320AbZKKUmJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 15:42:09 -0500
In-Reply-To: <200911112138.44074.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Octavian Purdila <opurdila@ixiacom.com>
Date: Wed, 11 Nov 2009 21:38:44 +0200

> I don't think we can dynamically size it at boot time since it
> depends on the usage pattern which is impossible to determine at
> boot time, right?

We have no idea how many sockets will be used by the system yet we
dynamically size the socket hash tables.

Please do some research and see how we handle this elsewhere in the
networking.
