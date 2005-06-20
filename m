From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: netpoll and the bonding driver
Date: Sun, 19 Jun 2005 20:21:20 -0400
Message-ID: <20050620002118.GA16859__4138.92121655426$1119226877$gmane$org@tuxdriver.com>
References: <17075.10995.498758.773092@segfault.boston.redhat.com> <20050619181436.GX27572@waste.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Moyer <jmoyer@redhat.com>, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Matt Mackall <mpm@selenic.com>
Content-Disposition: inline
In-Reply-To: <20050619181436.GX27572@waste.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Jun 19, 2005 at 11:14:36AM -0700, Matt Mackall wrote:
> On Fri, Jun 17, 2005 at 03:56:35PM -0400, Jeff Moyer wrote:

> > I'm trying to implement a netpoll hook for the bonding driver.
> 
> My first question would be: does this really make sense to do? Why not
> just bind netpoll to one of the underlying devices?

Depending on the bonding mode, this would be very unlikely to work.
The other side of the link will still be expecting to talk to the
bond rather than to an individual link.

John
-- 
John W. Linville
linville@tuxdriver.com
