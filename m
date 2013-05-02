From: David Miller <davem@davemloft.net>
Subject: Re: [GIT] Networking
Date: Thu, 02 May 2013 14:21:49 -0400 (EDT)
Message-ID: <20130502.142149.112188322974018320.davem@davemloft.net>
References: <20130502.135542.1332946768988319212.davem@davemloft.net>
	<20130502.140648.1138582574178897490.davem@davemloft.net>
	<1367518532.7757.14.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mirqus@gmail.com, torvalds@linux-foundation.org,
	hayeswang@realtek.com, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: dcbw@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1367518532.7757.14.camel@dcbw.foobar.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Williams <dcbw@redhat.com>
Date: Thu, 02 May 2013 13:15:32 -0500

> So it's got to be something else other than the netdev features ordering
> that's screwing up for Linus.  I'm sure we'd have heard about it a long,
> long time ago if something had messed up dev->flags bits...

We know for a fact that reordering the feature bits makes the link not
show as up in NM.

And we know that, when this happens, the driver and the kernel
internally both know that the link is up.

But how this ties into NM being confused about the link state is what
we're trying to find out.  It's still a mystery to me too.
