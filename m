From: "David S. Miller" <davem@redhat.com>
Subject: Re: RFC: NAPI packet weighting patch
Date: Wed, 22 Jun 2005 19:19:56 -0400 (EDT)
Message-ID: <20050622.191956.39166724.davem@redhat.com>
References: <20050622.132241.21929037.davem@davemloft.net>
	<200506222242.j5MMgbxS009935@guinness.s2io.com>
	<20050622231300.GC14251@wotan.suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: leonid.grossman@neterion.com, davem@davemloft.net, hadi@cyberus.ca,
        becker@scyld.com, rick.jones2@hp.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ak@suse.de
In-Reply-To: <20050622231300.GC14251@wotan.suse.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Andi Kleen <ak@suse.de>
Date: Thu, 23 Jun 2005 01:13:00 +0200

> The computing time must be quite long to be really a win.
> You need to waste a few hundred cycles at least on a modern fast CPU.

SKB allocation more than fits this requirement, and that is exactly
what the RX descriptor replenishment will do.

Even if SKB allocation was only half the necessary number of cycles
for the prefetch to hit the cpu, it'd still be a win.
