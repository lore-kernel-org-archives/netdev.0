From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/7] CAN: Add PF_CAN core module
Date: Fri, 16 Nov 2007 15:42:51 -0800 (PST)
Message-ID: <20071116.154251.89793380.davem@davemloft.net>
References: <ygfmytfbubd.fsf@janus.isnogud.escape.de>
	<20071115.040530.205831740.davem@davemloft.net>
	<ygfr6iqmfa3.fsf@janus.isnogud.escape.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, oliver@hartkopp.net,
	shemminger@linux-foundation.org, netdev@vger.kernel.org,
	kaber@trash.net, oliver.hartkopp@volkswagen.de
To: urs.thuermann@gmx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36840
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757369AbXKPXm6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2007 18:42:58 -0500
In-Reply-To: <ygfr6iqmfa3.fsf@janus.isnogud.escape.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Urs Thuermann <urs.thuermann@gmx.de>
Date: 16 Nov 2007 15:33:08 +0100

> I am not aware of any useful kernel facilities to replace our debug
> macros, i.e. printing of debug messages, controlled by a bit mask
> passed in as a module parameter, hexdumping of fames, etc.  Of course,
> there are other things like kprobes but sometimes printk(KERN_DEBUG...)
> is more convenient and that's why people write their own DBG() macros.

At the simplest level there is pr_debug() which replaces the
usual "print if DEBUG is defined" that lots of people use.

For device drivers we have something similar in dev_vdbg() et
al.

For bitmask based enabling yes it would be nice if there were
something more.  But you can also get this behavior by using
DEBUG, the above interfaces, and adjusting the kernel log level
to suit what you're trying to view.
