From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: ixgbe: RTNL assertion failed
Date: Sat, 4 May 2013 02:54:06 +0100
Message-ID: <20130504015406.GP2619@decadent.org.uk>
References: <20130503120907.4f13d41b@nehalam.linuxnetplumber.net>
 <F6FB0E698C9B3143BDF729DF222866464C28E112@ORSMSX110.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Skidmore, Donald C" <donald.c.skidmore@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:35311 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932306Ab3EDByN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 May 2013 21:54:13 -0400
Content-Disposition: inline
In-Reply-To: <F6FB0E698C9B3143BDF729DF222866464C28E112@ORSMSX110.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 03, 2013 at 11:17:39PM +0000, Skidmore, Donald C wrote:
> > -----Original Message-----
> > From: netdev-owner@vger.kernel.org [mailto:netdev-
> > owner@vger.kernel.org] On Behalf Of Stephen Hemminger
> > Sent: Friday, May 03, 2013 12:09 PM
> > To: Kirsher, Jeffrey T
> > Cc: netdev@vger.kernel.org
> > Subject: ixgbe: RTNL assertion failed
> > 
> > Running 3.9 kernel, ixgbe is splatting on resume from suspend.
> > 
> > [26430.213254] ixgbe 0000:01:00.0: setting latency timer to 64 [26430.213257]
> > RTNL: assertion failed at /build/buildd-linux_3.2.41-2-amd64-Wvc92F/linux-
> > 3.2.41/net/core/dev.c (1758) [26430.213259] Pid: 7839, comm: kworker/u:1
> > Not tainted 3.2.0-4-amd64 #1 Debian 3.2.41-2 [26430.213261] Call Trace:
[...]
> I'm having a little problem finding a path were we call netif_set_real_num_tx_queues without holding RTNL in net-next.  While looking over the stack dump one of our engineers noticed the text "Not tainted 3.2.0-4-amd64 #1 Debian 3.2.41-2 ".  Could this mean I'm looking over the wrong source?  It would make me feel better as I'm not seeing anything as is. :)

Indeed, this is not 3.9.

The version of ixgbe in this Debian kernel has bql support backported,
but is otherwise the same as in 3.2.41.  I assume that this bug has
been fixed some time between 3.2 and 3.9, but no-one requested that
the fix be included in stable branches.  Please can you identify the
fix?

Ben.

-- 
Ben Hutchings
We get into the habit of living before acquiring the habit of thinking.
                                                              - Albert Camus
