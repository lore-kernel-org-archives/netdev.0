From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/8] net: fix compilation NG when !CONFIG_MODULE
Date: Mon, 22 Sep 2008 19:00:52 -0700 (PDT)
Message-ID: <20080922.190052.32258463.davem@davemloft.net>
References: <200809222150.m8MLoZdf031857@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, h-shimamoto@ct.jp.nec.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49791
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753883AbYIWCBE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 22:01:04 -0400
In-Reply-To: <200809222150.m8MLoZdf031857@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Mon, 22 Sep 2008 14:50:35 -0700

> From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
> 
>   CC      net/core/dev.o
> net/core/dev.c:1001: error: redefinition of 'dev_load'
> include/linux/netdevice.h:1645: error: previous definition of 'dev_load' was here
> make[2]: *** [net/core/dev.o] Error 1
> 
> dev_load() is not used when CONFIG_MODULE disabled.
> 
> Signed-off-by: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Andrew, this problem got introduced by a tree other than networking.
Please push this to whatever subsystem tree added that
dev_load dummy decl in include/linux/netdevice.h

I don't see it in any trees I have here.
