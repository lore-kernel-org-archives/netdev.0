From: David Miller <davem@davemloft.net>
Subject: Re: [Patch] r8169: use u32 instead of unsigned long
Date: Fri, 28 May 2010 23:53:24 -0700 (PDT)
Message-ID: <20100528.235324.52183500.davem@davemloft.net>
References: <20100529040111.GA28225@host-a-55.ustcsz.edu.cn>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org
To: junchangwang@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51027
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751661Ab0E2GxO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 May 2010 02:53:14 -0400
In-Reply-To: <20100529040111.GA28225@host-a-55.ustcsz.edu.cn>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Junchang Wang <junchangwang@gmail.com>
Date: Sat, 29 May 2010 12:01:11 +0800

> RTL_R32 should return value with 32-bit width. But "unsigned long"
> implies u64 on some 64-bit platforms.
> 
> Signed-off-by: Junchang Wang <junchangwang@gmail.com>

I fail to see why there is a need to cast the return value
of readl() at all.

It returns a 32-bit integer on all platforms.

Secondly, 8139too.c has the same unnecessary cast.

So the thing to do is to kill the casts completely from both
drivers defining this register read macro.
