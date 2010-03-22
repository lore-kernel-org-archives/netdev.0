From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix PHY polling system blocking
Date: Sun, 21 Mar 2010 17:56:51 -0700 (PDT)
Message-ID: <20100321.175651.91333124.davem@davemloft.net>
References: <1267894258.18869.2.camel@wall-e>
	<20100312144248.ade8b700.akpm@linux-foundation.org>
	<1269208490.5748.44.camel@wall-e.seibold.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, tglx@linutronix.de
To: stefani@seibold.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1269208490.5748.44.camel@wall-e.seibold.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stefani Seibold <stefani@seibold.net>
Date: Sun, 21 Mar 2010 22:54:50 +0100

> The phylib has also a drawback, because it polls the PHY despite if it
> has interrupt support for it or not. I can't see a reason for this
> behavior.

Careful, in my experience many PHYs that do have interrupt
support have buggy implementations to the point where the
interrupt support cannot be used at all.

Typically the problem is that events aren't reported reliably.

So I just wanted you to keep in mind that a chip having
interrupt support doesn't automatically mean it can be used.
