From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 1/8] net: fix compilation NG when !CONFIG_MODULE
Date: Mon, 22 Sep 2008 21:12:14 -0700
Message-ID: <20080922211214.aeb08a7a.akpm@linux-foundation.org>
References: <200809222150.m8MLoZdf031857@imap1.linux-foundation.org>
	<20080922.190052.32258463.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, h-shimamoto@ct.jp.nec.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:60754 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750827AbYIWEMs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 00:12:48 -0400
In-Reply-To: <20080922.190052.32258463.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 22 Sep 2008 19:00:52 -0700 (PDT) David Miller <davem@davemloft.net> wrote:

> From: akpm@linux-foundation.org
> Date: Mon, 22 Sep 2008 14:50:35 -0700
> 
> > From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
> > 
> >   CC      net/core/dev.o
> > net/core/dev.c:1001: error: redefinition of 'dev_load'
> > include/linux/netdevice.h:1645: error: previous definition of 'dev_load' was here
> > make[2]: *** [net/core/dev.o] Error 1
> > 
> > dev_load() is not used when CONFIG_MODULE disabled.
> > 
> > Signed-off-by: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
> > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> 
> Andrew, this problem got introduced by a tree other than networking.
> Please push this to whatever subsystem tree added that
> dev_load dummy decl in include/linux/netdevice.h
> 
> I don't see it in any trees I have here.

OK, I don't see the failure either, so I assume that whichever tree
busted things (rusty?) was indepentently fixed.  I'll drop it, thanks.


