From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH] mac80211: include <linux/delay.h> instead of <asm/delay.h>
Date: Sun, 6 May 2007 16:48:26 -0400
Message-ID: <20070506204826.GA11238@tuxdriver.com>
References: <Pine.LNX.4.64.0705062236030.4741@anakin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>,
	Jiri Benc <jbenc@suse.cz>, netdev@vger.kernel.org,
	Linux Kernel Development <linux-kernel@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:3392 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756025AbXEFVC3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 May 2007 17:02:29 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0705062236030.4741@anakin>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, May 06, 2007 at 10:37:17PM +0200, Geert Uytterhoeven wrote:
> |   CC      net/mac80211/ieee80211_sta.o
> | In file included from linux/net/mac80211/ieee80211_sta.c:31:
> | include2/asm/delay.h: In function '__const_udelay':
> | include2/asm/delay.h:33: error: 'loops_per_jiffy' undeclared (first use in this function)
> | include2/asm/delay.h:33: error: (Each undeclared identifier is reported only once
> | include2/asm/delay.h:33: error: for each function it appears in.)
> 
> mac80211: include <linux/delay.h> instead of <asm/delay.h>

Got it, thanks!

Please send/copy to linux-wireless@vger.kernel.org in the future.

John
-- 
John W. Linville
linville@tuxdriver.com
