From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] "lockless loopback" patch for 2.6.6
Date: Sat, 22 May 2004 14:20:55 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040522122055.GC2118@wotan.suse.de>
References: <Pine.SGI.4.56.0405111251080.7038576@neteng.engr.sgi.com> <20040512120810.464aaee6.davem@redhat.com> <Pine.SGI.4.56.0405121256510.7328714@neteng.engr.sgi.com> <Pine.SGI.4.56.0405211356440.8333289@neteng.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Arthur Kepner <akepner@sgi.com>
Content-Disposition: inline
In-Reply-To: <Pine.SGI.4.56.0405211356440.8333289@neteng.engr.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, May 21, 2004 at 02:04:09PM -0700, Arthur Kepner wrote:
> 
> Lock contention on the loopback device can lead to poor
> performance, even an essentially hung system, on systems
> with many processors.
> 
> For the loopback device, the only purpose that locking serves
> is to protect the device statistics. The attached patch
> keeps per-cpu statistics for the loopback device and removes
> all locking. The patch is against 2.6.6.

[...]

It looks quite ugly. How about you just create multiple loopback devices
and use these preferably from specific CPUs ? 

One loopback device per CPU would be probably overkill, but maybe one
per 8 CPUs.

-Andi
