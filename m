From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] "lockless loopback" patch for 2.6.6
Date: Fri, 21 May 2004 14:45:57 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040521144557.6a2c6a02.davem@redhat.com>
References: <Pine.SGI.4.56.0405111251080.7038576@neteng.engr.sgi.com>
	<20040512120810.464aaee6.davem@redhat.com>
	<Pine.SGI.4.56.0405121256510.7328714@neteng.engr.sgi.com>
	<Pine.SGI.4.56.0405211356440.8333289@neteng.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Arthur Kepner <akepner@sgi.com>
In-Reply-To: <Pine.SGI.4.56.0405211356440.8333289@neteng.engr.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 21 May 2004 14:04:09 -0700
Arthur Kepner <akepner@sgi.com> wrote:

> Lock contention on the loopback device can lead to poor
> performance, even an essentially hung system, on systems
> with many processors.
> 
> For the loopback device, the only purpose that locking serves
> is to protect the device statistics. The attached patch
> keeps per-cpu statistics for the loopback device and removes
> all locking. The patch is against 2.6.6.

It is legal to attach queueing disciplines to the loopback device
but your patch makes that impossible.

I don't think it is worth worrying about things like this especially
if you're going to be adding ugly loopback special cases to the
generic device handling code like this.
