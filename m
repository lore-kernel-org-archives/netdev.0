From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Fw: b44 ifconfig fails with ENOMEM
Date: Tue, 4 Jan 2005 14:20:26 -0800
Message-ID: <20050104142026.000be2e8.davem@davemloft.net>
References: <20050103191836.57f918e5.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20050103191836.57f918e5.akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 3 Jan 2005 19:18:36 -0800
Andrew Morton <akpm@osdl.org> wrote:

> b44 requires an order-8 allocation?  Good luck...

Yes, it allocates a full TX ring worth of bounce buffers
to work around a DMA addressing limitation.  It should do
a bunch of smaller consistent allocations instead of one
huge one, that's for sure.
