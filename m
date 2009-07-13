From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET: Fix locking issues in PPP, 6pack, mkiss and strip
 line disciplines.
Date: Sun, 12 Jul 2009 21:07:30 -0700 (PDT)
Message-ID: <20090712.210730.170014470.davem@davemloft.net>
References: <20090712172720.GA7313@linux-mips.org>
	<20090712222658.GC26798@linux-mips.org>
	<20090712234854.10cfcef2@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, netdev@vger.kernel.org,
	guido@trentalancia.com, paulus@samba.org,
	linux-hams@vger.kernel.org, hans@esrac.ele.tue.nl
To: alan@lxorguk.ukuu.org.uk
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <20090712234854.10cfcef2@lxorguk.ukuu.org.uk>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Date: Sun, 12 Jul 2009 23:48:54 +0100

>> The issue was, that the locking code in mkiss was assuming it was only
>> ever being called in process or bh context.  Fixed by converting the
>> involved locking code to use irq-safe locks.
> 
> Which historically of course was correct until the networking layer
> changed behaviour some years ago.

Networking layer?  Surely you mean the TTY layer or USB because I
don't see anything networking in his traces :-)

> These look good to me.

Thanks for reviewing, I'll apply his patch.
