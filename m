From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/8] netpoll: Allow netpoll_setup/cleanup recursion
Date: Thu, 24 Jun 2010 21:52:06 -0700 (PDT)
Message-ID: <20100624.215206.258121498.davem@davemloft.net>
References: <20100624205059.a28756b0.akpm@linux-foundation.org>
	<20100624.212713.242141362.davem@davemloft.net>
	<20100624214204.a85c8ba2.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.hengli.com.au, mst@redhat.com, frzhang@redhat.com,
	netdev@vger.kernel.org, amwang@redhat.com, shemminger@vyatta.com,
	mpm@selenic.com, paulmck@linux.vnet.ibm.com,
	a.p.zijlstra@chello.nl, mingo@elte.hu
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33871
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751307Ab0FYEvy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jun 2010 00:51:54 -0400
In-Reply-To: <20100624214204.a85c8ba2.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Thu, 24 Jun 2010 21:42:04 -0700

> I'd imagine that netconsole would get in the way rather a lot for net
> developers, but it's really useful!

I have a fully logging stable serial or hypervisor console on every
one of my boxes, why would I even bother?

> That being said, I wonder why Herbert didn't hit this in his testing. 
> I suspect that he'd enabled lockdep, which hid the bug.  I haven't
> worked out _why_ lockdep hides the double-mutex_unlock bug, but it's a
> pretty bad thing to do.

Yes, definitely something to look into.
