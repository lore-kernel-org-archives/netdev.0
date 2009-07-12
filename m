From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] NET: Fix locking issues in PPP, 6pack, mkiss and strip
 line disciplines.
Date: Sun, 12 Jul 2009 23:48:54 +0100
Message-ID: <20090712234854.10cfcef2@lxorguk.ukuu.org.uk>
References: <20090712172720.GA7313@linux-mips.org>
	<20090712222658.GC26798@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Guido Trentalancia <guido@trentalancia.com>,
	Paul Mackerras <paulus@samba.org>, linux-hams@vger.kernel.org,
	Hans Albas PE1AYX <hans@esrac.ele.tue.nl>
To: Ralf Baechle DL5RB <ralf@linux-mips.org>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <20090712222658.GC26798@linux-mips.org>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> The issue was, that the locking code in mkiss was assuming it was only
> ever being called in process or bh context.  Fixed by converting the
> involved locking code to use irq-safe locks.

Which historically of course was correct until the networking layer
changed behaviour some years ago.

These look good to me.
