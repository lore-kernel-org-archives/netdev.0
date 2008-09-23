From: "Randy.Dunlap" <rdunlap@xenotime.net>
Subject: Re: [patch 1/8] net: fix compilation NG when !CONFIG_MODULE
Date: Tue, 23 Sep 2008 08:47:59 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0809230846410.27041@shark.he.net>
References: <200809222150.m8MLoZdf031857@imap1.linux-foundation.org>
 <20080922.190052.32258463.davem@davemloft.net> <20080922211214.aeb08a7a.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	h-shimamoto@ct.jp.nec.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenotime.net ([66.160.160.81]:54991 "HELO xenotime.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751452AbYIWPsI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Sep 2008 11:48:08 -0400
Received: from shark.he.net ([66.160.160.2]) by xenotime.net for <netdev@vger.kernel.org>; Tue, 23 Sep 2008 08:47:59 -0700
In-Reply-To: <20080922211214.aeb08a7a.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 22 Sep 2008, Andrew Morton wrote:

> On Mon, 22 Sep 2008 19:00:52 -0700 (PDT) David Miller <davem@davemloft.net> wrote:
> 
> > From: akpm@linux-foundation.org
> > Date: Mon, 22 Sep 2008 14:50:35 -0700
> > 
> > > From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
> > > 
> > >   CC      net/core/dev.o
> > > net/core/dev.c:1001: error: redefinition of 'dev_load'
> > > include/linux/netdevice.h:1645: error: previous definition of 'dev_load' was here
> > > make[2]: *** [net/core/dev.o] Error 1
> > > 
> > > dev_load() is not used when CONFIG_MODULE disabled.
> > > 
> > > Signed-off-by: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
> > > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> > 
> > Andrew, this problem got introduced by a tree other than networking.
> > Please push this to whatever subsystem tree added that
> > dev_load dummy decl in include/linux/netdevice.h
> > 
> > I don't see it in any trees I have here.
> 
> OK, I don't see the failure either, so I assume that whichever tree
> busted things (rusty?) was indepentently fixed.  I'll drop it, thanks.

You asked Rusty to fix it on 2008-SEP-08 here:
http://marc.info/?l=linux-kernel&m=122091240810285&w=2
and Alexey D.'s patch is here:
http://marc.info/?l=linux-netdev&m=122064308827637&w=2

-- 
~Randy
