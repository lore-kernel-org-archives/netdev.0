From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH] remove FCS from pktgen bandwidth calculation
Date: Fri, 10 Dec 2004 08:25:50 +0100
Message-ID: <20041210072549.GA30446@xi.wantstofly.org>
References: <20041208201116.GA10691@xi.wantstofly.org> <16824.22466.897897.238619@robur.slu.se> <20041209155936.69313e70.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Robert Olsson <Robert.Olsson@data.slu.se>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041209155936.69313e70.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Dec 09, 2004 at 03:59:36PM -0800, David S. Miller wrote:

> > OK! We strictly define statistics to be based on the data we deliver
> > to hard_xmit. Feel free to change the current kernel version... while
> > we wait for 2.7 :-)
> 
> Robert can you collect together the various pktgen patches
> that have been floating about over the past few days and
> send to me what you think should be applied.
> 
> There is this FCS patch, and the naonspin one from Lennert
> as well.  There may have been others.

At least the nanospin patch won't apply cleanly against the pktgen
version currently in mainline.  I'm reworking it anyway since it's
actually buggy -- give me a day or two and I'll post updated patches
against 2.6 as well as Robert's devel version.

(See ftp://robur.slu.se/pub/Linux/net-development/pktgen-testing/ for
Robert's devel versions.)


cheers,
Lennert
