From: David Miller <davem@davemloft.net>
Subject: Re: [GIT]: Networking
Date: Sun, 20 Jul 2008 18:14:40 -0700 (PDT)
Message-ID: <20080720.181440.122144107.davem@davemloft.net>
References: <alpine.LFD.1.10.0807201751440.31863@woody.linux-foundation.org>
	<20080720.180304.51601407.davem@davemloft.net>
	<20080721010952.GA4822@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36831
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755314AbYGUBOk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jul 2008 21:14:40 -0400
In-Reply-To: <20080721010952.GA4822@martell.zuzino.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Mon, 21 Jul 2008 05:09:52 +0400

> > > > This is the main networking merge for 2.6.27
> 
> Looks like multiqueue changes broken netconsole (it remains silent).

Can you dig a little bit deeper into this one?  It ought to
work fine.

Thanks.

> Also, I had to enable CONFIG_NET_SCHED=y, otherwise it wouldn't link:

I just pushed Linus a fix for that, Stephen Rothwell noticed it
too.

> And finally, boot process hangs after TCP cubic is initialized.

That very much should not happen.  Can you turn on initcall
tracing so we can see where that is happening exactly?
