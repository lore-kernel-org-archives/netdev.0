From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mac80211: include <linux/delay.h> instead of
 <asm/delay.h>
Date: Tue, 08 May 2007 18:40:47 -0700 (PDT)
Message-ID: <20070508.184047.122618515.davem@davemloft.net>
References: <20070508155011.GD6479@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54021
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S967801AbXEIBkq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 May 2007 21:40:46 -0400
In-Reply-To: <20070508155011.GD6479@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Tue, 8 May 2007 11:50:11 -0400

> From: Geert Uytterhoeven <geert@linux-m68k.org>
> 
> |   CC      net/mac80211/ieee80211_sta.o
> | In file included from linux/net/mac80211/ieee80211_sta.c:31:
> | include2/asm/delay.h: In function '__const_udelay':
> | include2/asm/delay.h:33: error: 'loops_per_jiffy' undeclared (first use in this function)
> | include2/asm/delay.h:33: error: (Each undeclared identifier is reported only once
> | include2/asm/delay.h:33: error: for each function it appears in.)
> 
> mac80211: include <linux/delay.h> instead of <asm/delay.h>
> 
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
> Signed-off-by: John W. Linville <linville@tuxdriver.com>

Applied, thanks everyone.
