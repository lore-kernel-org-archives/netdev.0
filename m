From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH,RFC] pktgen sleeping/timing rework
Date: Thu, 16 Dec 2004 15:42:47 +0100
Message-ID: <20041216144247.GA4109@xi.wantstofly.org>
References: <20041210222058.GA5984@xi.wantstofly.org> <16830.58158.882590.971712@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
Content-Disposition: inline
In-Reply-To: <16830.58158.882590.971712@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Dec 14, 2004 at 01:57:18PM +0100, Robert Olsson wrote:

> Timing code gets cleaner and bit more predictable at least we know
> better now how to arrange delay for lower rates. It still need some
> experimentation.

Sorting out the pps rate discrepancies for >10kpps was next on my
list of things to do.  I think fixing this is doable.


> Appplied this to the development version and also renamed ipg to delay.
> It breaks some scripts. We need a variant and of this and the FCS patch 
> for the kernel version.

Is it sane to try and keep pktgen-2.6 up to date when the devel
version is so much more flexible?


cheers,
Lennert
