From: Urs Thuermann <urs.thuermann@gmx.de>
Subject: Re: [PATCH 2/7] CAN: Add PF_CAN core module
Date: 16 Nov 2007 15:33:08 +0100
Message-ID: <ygfr6iqmfa3.fsf@janus.isnogud.escape.de>
References: <473BF7FD.7010403@hartkopp.net>
	<1195113860.27113.34.camel@localhost>
	<ygfmytfbubd.fsf@janus.isnogud.escape.de>
	<20071115.040530.205831740.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: joe@perches.com, oliver@hartkopp.net,
	shemminger@linux-foundation.org, netdev@vger.kernel.org,
	kaber@trash.net, oliver.hartkopp@volkswagen.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oker.escape.de ([194.120.234.254]:42535 "EHLO oker.escape.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933927AbXKPOf2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Nov 2007 09:35:28 -0500
In-Reply-To: <20071115.040530.205831740.davem@davemloft.net>; from David Miller on Thu, 15 Nov 2007 04:05:30 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

> I really frown upon these local debugging macros people tend to want
> to submit with their changes.
> 
> It really craps up the tree, even though it might be useful to you.

We have now removed the debug code completely.  The code is quite
stable and we won't need these remnants from early days anymore.

> So please remove this stuff or replace the debugging statements
> with some generic kernel debugging facility, there are several.

I am not aware of any useful kernel facilities to replace our debug
macros, i.e. printing of debug messages, controlled by a bit mask
passed in as a module parameter, hexdumping of fames, etc.  Of course,
there are other things like kprobes but sometimes printk(KERN_DEBUG...)
is more convenient and that's why people write their own DBG() macros.

urs
