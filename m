From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 09/12] net/eipoib: Add main driver functionality
Date: Fri, 03 Aug 2012 16:36:27 -0700 (PDT)
Message-ID: <20120803.163627.1867181085116225405.davem@davemloft.net>
References: <501C3527.6060809@mellanox.com>
	<20120803.143315.151094375569109262.davem@davemloft.net>
	<501C5328.4060301@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, ogerlitz@mellanox.com, roland@kernel.org,
	netdev@vger.kernel.org, sean.hefty@intel.com, erezsh@mellanox.co.il
To: ali@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41581 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753927Ab2HCXgg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Aug 2012 19:36:36 -0400
In-Reply-To: <501C5328.4060301@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ali Ayoub <ali@mellanox.com>
Date: Fri, 03 Aug 2012 15:39:36 -0700

> Users would like to use sockets API from the VM without re-writing their
> applications on top of IB verbs, this driver meant to allow such a user
> to do so.

That's what IPoIB was for, the application writers who don't want to have
to be knowledgable about IB verbs.

You're messing with the link layer here, and that's what is upsetting me.

It's a complete cop-out to changing the VM tools and emulators properly to
handle a new link layer.

The applications writers already have a way to use IB whilst using
something familiar, like IPv4, via IPoIB.  You're doing something
completely different here, and it stinks.
