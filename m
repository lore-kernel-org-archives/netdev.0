From: David Miller <davem@davemloft.net>
Subject: Re: [2.6.23-rc4-mm1][Bug] kernel BUG at
 include/linux/netdevice.h:339!
Date: Mon, 17 Sep 2007 16:13:33 -0700 (PDT)
Message-ID: <20070917.161333.38709774.davem@davemloft.net>
References: <46EE7026.2070203@linux.vnet.ibm.com>
	<20070917141622.330b27b8.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kamalesh@linux.vnet.ibm.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60401
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753478AbXIQXNh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2007 19:13:37 -0400
In-Reply-To: <20070917141622.330b27b8.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@linux-foundation.org>
Date: Mon, 17 Sep 2007 14:16:22 -0700

> On Mon, 17 Sep 2007 17:46:38 +0530
> Kamalesh Babulal <kamalesh@linux.vnet.ibm.com> wrote:
> 
> > Kernel Bug is hit with 2.6.23-rc4-mm1 kernel on ppc64 machine.
> > 
> > kernel BUG at include/linux/netdevice.h:339!
> 
> (please cc netdev@vger.kernel.org on networking-related matters)
> 
> You died here:
> 
> static inline void napi_complete(struct napi_struct *n)
> {
>         BUG_ON(!test_bit(NAPI_STATE_SCHED, &n->state));
> 
> The NAPI changes have had a few problems and hopefully things have
> been fixed up since then.  I'll try to get rc6-mm1 out this evening,
> so please retest that?

And if you trigger this still it is absolutely critical that
you tell us what networking device driver you are using at
the time.
