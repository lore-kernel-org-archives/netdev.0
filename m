From: David Miller <davem@davemloft.net>
Subject: Re: [bug, netconsole, SLUB] BUG skbuff_head_cache: Poison
 overwritten
Date: Thu, 17 Jul 2008 14:45:04 -0700 (PDT)
Message-ID: <20080717.144504.96425101.davem@davemloft.net>
References: <20080717214222.GA29449@elte.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	penberg@cs.helsinki.fi, vegard.nossum@gmail.com, rjw@sisk.pl
To: mingo@elte.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41466
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757273AbYGQVpF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2008 17:45:05 -0400
In-Reply-To: <20080717214222.GA29449@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ingo Molnar <mingo@elte.hu>
Date: Thu, 17 Jul 2008 23:42:22 +0200

> 
> A regression to v2.6.26:
> 
> I started getting this skb-head corruption message today, on a T60 
> laptop with e1000:

This is very unlikely to be added by us networking folks, no
networking merges have happened for the 2.6.27 merge window yet :-)
