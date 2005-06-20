From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: netpoll and the bonding driver
Date: Mon, 20 Jun 2005 11:01:14 -0400
Message-ID: <17078.55866.893715.792418__39248.4395568774$1119279805$gmane$org@segfault.boston.redhat.com>
References: <17075.10995.498758.773092@segfault.boston.redhat.com>
	<20050619181436.GX27572@waste.org>
	<20050620002118.GA16859@tuxdriver.com>
Reply-To: jmoyer@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Matt Mackall <mpm@selenic.com>, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20050620002118.GA16859@tuxdriver.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

==> Regarding Re: netpoll and the bonding driver; "John W. Linville" <linville@tuxdriver.com> adds:

linville> On Sun, Jun 19, 2005 at 11:14:36AM -0700, Matt Mackall wrote:
>> On Fri, Jun 17, 2005 at 03:56:35PM -0400, Jeff Moyer wrote:

>> > I'm trying to implement a netpoll hook for the bonding driver.
>> 
>> My first question would be: does this really make sense to do? Why not
>> just bind netpoll to one of the underlying devices?

linville> Depending on the bonding mode, this would be very unlikely to
linville> work.  The other side of the link will still be expecting to talk
linville> to the bond rather than to an individual link.

Right, and for those drivers which register a netpoll_rx routine, they may
not get all of the packets destined for them.

-Jeff
