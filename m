From: Jiri Kosina <jikos@jikos.cz>
Subject: Re: 2.6.21-git8+ BUG: NMI Watchdog detected LOCKUP on CPU1
Date: Tue, 8 May 2007 18:09:42 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0705081807100.16923@twin.jikos.cz>
References: <46403642.7020501@googlemail.com> <20070508030701.d21dc40b.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from twin.jikos.cz ([213.151.79.26]:54511 "EHLO twin.jikos.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934567AbXEHQJx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 May 2007 12:09:53 -0400
In-Reply-To: <20070508030701.d21dc40b.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 8 May 2007, Andrew Morton wrote:

>   happens when a local process sends packets with invalid IP headers
>   through raw sockets.
[...]
> Whatever happens, that printk should be toned down, shouldn't it?  We
> prefer to not let unprivileged apps spam the logs.

Isn't "unprivileged app sending packet through raw socket" an oxymoron? As 
Patrick pointed out, the message is there for a reason, I'd suggest using 
printk_ratelimit() in this case.

-- 
Jiri Kosina
