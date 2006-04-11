From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [RFC/PATCH] remove unneeded check in bcm43xx
Date: Wed, 12 Apr 2006 08:20:28 +1000
Message-ID: <1144794028.19353.51.camel@localhost.localdomain>
References: <1144719972.19353.24.camel@localhost.localdomain>
	 <20060410.224933.39567033.davem@davemloft.net>
	 <1144788541.19353.41.camel@localhost.localdomain>
	 <20060411.143407.74615246.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: benoit.boissinot@ens-lyon.org, mb@bu3sch.de,
	netdev@vger.kernel.org, bcm43xx-dev@lists.berlios.de,
	linux-kernel@vger.kernel.org, linville@tuxdriver.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751165AbWDKWVG@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060411.143407.74615246.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-04-11 at 14:34 -0700, David S. Miller wrote:

> I still think we shouldn't reward shit hardware by complicating
> up our DMA mappings internals. :-)

Heh, it's a good point but in that specific case, it's a bit difficult
to tell that to users who don't have a choice of what card to put in
apple proprietary slot ... =P

> If you're going to do it anyways, we use a nearly identical
> allocation bitmap algorithm under sparc64 so maybe you can
> take a stab at trying to put your code there too.  I'm more
> than happy to test and integrate.

I may give it a go later this week. I don't have a wireless card in my
g5 so I'll need to ping-pong the patch with testers first tho.

Ben.
