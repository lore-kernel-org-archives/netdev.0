From: David Miller <davem@davemloft.net>
Subject: Re: [Patch 4/5] Network Drop Monitor: Adding drop monitor
 implementation & Netlink protocol
Date: Wed, 04 Mar 2009 03:00:44 -0800 (PST)
Message-ID: <20090304.030044.163418715.davem@davemloft.net>
References: <20090303192107.GJ1480@hmsreliant.think-freely.org>
	<20090303.141612.160287111.davem@davemloft.net>
	<49AE52B1.3020200@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, zbr@ioremap.net, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52140
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750868AbZCDLA7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2009 06:00:59 -0500
In-Reply-To: <49AE52B1.3020200@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Wed, 04 Mar 2009 11:06:41 +0100

> It should also be noted that netlink attributes only provide 4 byte
> alignment. Not sure what the current status of handling unaligned
> accesses on all architectures is, but something that might have to
> be taken into consideration.

Indeed, we have hacks in libnl to work around some of these
issues :-(
