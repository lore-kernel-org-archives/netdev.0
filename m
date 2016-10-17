From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/15] ethernet: use core min/max MTU checking
Date: Mon, 17 Oct 2016 16:03:41 -0400 (EDT)
Message-ID: <20161017.160341.529517225075047124.davem@davemloft.net>
References: <20161017195417.48259-1-jarod@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: jarod@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161017195417.48259-1-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jarod Wilson <jarod@redhat.com>
Date: Mon, 17 Oct 2016 15:54:02 -0400

> For the most part, every patch does the same essential thing: removes the
> MTU range checking from the drivers' ndo_change_mtu function, puts those
> ranges into the core net_device min_mtu and max_mtu fields, and where
> possible, removes ndo_change_mtu functions entirely.

Jarod, please read my other posting.

You've positively broken the maximum MTU for all of these drivers.

That's not cool.

And this series fixing things doesn't make things better, because now
we've significanyly broken bisection for anyone running into this
regression.

You should have arranged this in such a way that the drivers needing
> 1500 byte MTU were not impacted at all by your changes, but that
isn't what happened.
