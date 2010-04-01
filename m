From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 04/12] l2tp: Add ppp device name to L2TP ppp session
 data
Date: Thu, 01 Apr 2010 00:34:59 -0700 (PDT)
Message-ID: <20100401.003459.88028238.davem@davemloft.net>
References: <4BB2FD0D.1080105@katalix.com>
	<20100331160811.16351eb7@s6510>
	<4BB4490F.8090406@katalix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: jchapman@katalix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51133
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751209Ab0DAHe6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 03:34:58 -0400
In-Reply-To: <4BB4490F.8090406@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: James Chapman <jchapman@katalix.com>
Date: Thu, 01 Apr 2010 08:19:43 +0100

> There might be thousands of L2TP sessions in some setups. Populating
> sysfs with a link for each of those sessions isn't practical. The
> existing /proc file dumps its info as a single text file for this
> reason. I'd also like to provide the device name in the session netlink
> message, which is the interface used by l2tp userspace, so I need a
> kernel API to retrieve the device name from ppp.

Scalability concerns are also another reason _not_ to use
procfs.

Use netlink or similar, which can dump with filtering and
proper queueing.
