From: "David S. Miller" <davem@davemloft.net>
Subject: Re: recommendations for NIC HW(/SW) design?
Date: Sun, 26 Sep 2004 20:53:04 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040926205304.06cf1de6.davem@davemloft.net>
References: <20040926152955.GD17043@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20040926152955.GD17043@xi.wantstofly.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 26 Sep 2004 17:29:55 +0200
Lennert Buytenhek <buytenh@wantstofly.org> wrote:

> Does any of you have any general recommendations for this?  Is there
> anything I should certainly implement, or any design mistakes that I
> should certainly avoid?

The best thing I think the tg3 does is that it uses 3
rings for packet management.

There is one transmit ring, one receive ring, and "response"
ring.

The cpu only writes to the first two rings, and the chip
only writes to the third ring.  And this is great for cache
behavior on the bus.
