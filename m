From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 09/12] net/eipoib: Add main driver functionality
Date: Fri, 03 Aug 2012 14:33:15 -0700 (PDT)
Message-ID: <20120803.143315.151094375569109262.davem@davemloft.net>
References: <1343840975-3252-10-git-send-email-ogerlitz@mellanox.com>
	<87boitz044.fsf@xmission.com>
	<501C3527.6060809@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, ogerlitz@mellanox.com, roland@kernel.org,
	netdev@vger.kernel.org, sean.hefty@intel.com, erezsh@mellanox.co.il
To: ali@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40761 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752377Ab2HCVdQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Aug 2012 17:33:16 -0400
In-Reply-To: <501C3527.6060809@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ali Ayoub <ali@mellanox.com>
Date: Fri, 03 Aug 2012 13:31:35 -0700

> With eIPoIB architecture, the VM sees standard Ethernet emulator,
> allowing the administrator to enslave eIPoIB PIF to the vSwitch/vBridge
> as if it was standard Ethernet. Other approaches that exposes IB QP to
> the VM (with w/o bypassing the kernel) won't be possible with the
> current emulators and management tools.

So then fix the emulators and management tools to handle IB instead
of adding this bogus new protocol?

This new protocol seems to exist only because you don't want to have
to enhance the emulators and tools, and I'm sorry that isn't a valid
reason to do something like this.
