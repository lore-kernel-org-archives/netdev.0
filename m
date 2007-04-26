From: David Miller <davem@davemloft.net>
Subject: Re: [patch 10/15] ppp_generic: fix lockdep warning
Date: Thu, 26 Apr 2007 01:39:11 -0700 (PDT)
Message-ID: <20070426.013911.69219176.davem@davemloft.net>
References: <200704260727.l3Q7RTxG023970@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jarkao2@o2.pl, jura@netams.com,
	paulus@samba.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56521
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933617AbXDZIjE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 04:39:04 -0400
In-Reply-To: <200704260727.l3Q7RTxG023970@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@linux-foundation.org
Date: Thu, 26 Apr 2007 00:27:29 -0700

> lockdep has seen locks "-> #0" - "-> #3" taken in circular order, but IMHO,
> lock "-> #3" (&pch->downl) taken after "-> #2" (&ppp->wlock) differs from
> &pch->downl lock taken in "-> #0" (before &vlan_netdev_xmit_lock_key) and
> lockdep should be notified about this.
> 
> Reported & tested by: "Yuriy N. Shkandybin" <jura@netams.com>
> Signed-off-by: Jarek Poplawski <jarkao2@o2.pl>
> Cc: Paul Mackerras <paulus@samba.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

I believe there were some problems found in this one,
so I'm going to hold on it for now.
