From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v3] ipv4: allow warming up the ARP cache with
 request type gratuitous ARP
Date: Tue, 19 Jan 2010 03:13:43 -0800 (PST)
Message-ID: <20100119.031343.44943528.davem@davemloft.net>
References: <20100119100913.65177497@opy.nosense.org>
	<20100119.021138.172154379.davem@davemloft.net>
	<20100119211818.28f48713@opy.nosense.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: opurdila@ixiacom.com, ja@ssi.bg, chavey@google.com,
	netdev@vger.kernel.org
To: lk-netdev@lk-netdev.nosense.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44139
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932178Ab0ASLNf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2010 06:13:35 -0500
In-Reply-To: <20100119211818.28f48713@opy.nosense.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Date: Tue, 19 Jan 2010 21:18:18 +1030

> ARP_ACCEPT / the /proc "arp_accept" file is really confusingly named -
> unless you knew better I doubt anybody would guess it's only referring
> to GARPs. Is there any chance of renaming it or symlinking a new name
> of something like "garp_accept" to the old one? Is this a significant
> enough behaviour change that it creates that opportunity?

It's been there forever, it's well documented, and creating
symlinks is messy.

So no.
