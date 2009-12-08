From: David Miller <davem@davemloft.net>
Subject: Re: ipv6: why disable ipv6 on last address removal?
Date: Tue, 08 Dec 2009 12:56:11 -0800 (PST)
Message-ID: <20091208.125611.135547597.davem@davemloft.net>
References: <20091208192046.GA5649@midget.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: jbohac@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53433
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S966102AbZLHU4F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2009 15:56:05 -0500
In-Reply-To: <20091208192046.GA5649@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Bohac <jbohac@suse.cz>
Date: Tue, 8 Dec 2009 20:20:46 +0100

> Is there any reason why inet6_addr_del needs to sets how=1 and
> disable IPv6 even more than "ifconfig down" does?

All I can say is that this behavior is definitely on purpose, although
I don't exactly remember why.

And although it helps you, it could also break things for other people
who expect the current behavior.

Some people definitely expect no IPV6 at all in any way shape or
form if they have not assigned IPV6 addresses to an interface.
