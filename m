From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix CAN info leak/minor heap overflow
Date: Wed, 10 Nov 2010 09:51:41 -0800 (PST)
Message-ID: <20101110.095141.226780406.davem@davemloft.net>
References: <4CD8FDB5.6060905@hartkopp.net>
	<20101109.090523.189685701.davem@davemloft.net>
	<4CDA412B.90900@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: urs@isnogud.escape.de, netdev@vger.kernel.org,
	drosenberg@vsecurity.com, security@kernel.org,
	torvalds@linux-foundation.org
To: socketcan@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38317
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754599Ab0KJRvR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Nov 2010 12:51:17 -0500
In-Reply-To: <4CDA412B.90900@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Hartkopp <socketcan@hartkopp.net>
Date: Wed, 10 Nov 2010 07:52:27 +0100

> IMHO the patch improves the historic situation and fixes the useless leakage
> of kernel addresses. Please consider to apply that procfs changes.

I'm only fine with fixing the kernel pointer fields in some way.

But moving forward any other change to the procfs file is simply
a waste of time.

You should create sysfs files and add logic to your tools to look
for them and use them if they exist.

Your forward path _SHOULD NOT_ be continuing this procfs versioning
madness.  Use something sane and do the work to make userland start
to be ready for this transition.
