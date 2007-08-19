From: David Miller <davem@davemloft.net>
Subject: Re: [ofa-general] Re: [PATCH RFC] RDMA/CMA: Allocate
	PS_TCPportsfrom the host TCP port space.
Date: Sun, 19 Aug 2007 12:32:12 -0700 (PDT)
Message-ID: <20070819.123212.13769462.davem@davemloft.net>
References: <000001c7e22e$b7b90f00$29c8180a@amr.corp.intel.com>
	<20070819.002337.06589160.davem@davemloft.net>
	<8A71B368A89016469F72CD08050AD334018E208F@maui.asicdesigners.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, rdreier@cisco.com,
	linux-kernel@vger.kernel.org, general@lists.openfabrics.org
To: felix@chelsio.com
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <8A71B368A89016469F72CD08050AD334018E208F@maui.asicdesigners.com>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

From: "Felix Marti" <felix@chelsio.com>
Date: Sun, 19 Aug 2007 10:33:31 -0700

> I know that you don't agree that TSO has drawbacks, as outlined by
> Roland, but its history showing something else: the addition of TSO
> took a fair amount of time and network performance was erratic for
> multiple kernel revisions and the TSO code is sprinkled across the
> network stack.

This thing you call "sprinkled" is a necessity of any hardware
offload when it is possible for a packet to later get "steered"
to a device which cannot perform the offload.

Therefore we need a software implementation of TSO so that those
packets can still get output to the non-TSO-capable device.

We do the same thing for checksum offloading.

And for free we can use the software offloading mechanism to
get batching to arbitrary network devices, even those which cannot
do TSO.

What benefits does RDMA infrastructure give to non-RDMA capable
devices?  None?  I see, that's great.

And again the TSO bugs and issues are being overstated and, also for
the second time, these issues are more indicative of my bad
programming skills then they are of intrinsic issues of TSO.  The
TSO implementation was looking for a good design, and it took me
a while to find it because I personally suck.

Face it, stateless offloads are always going to be better in the long
term.  And this is proven.

You RDMA folks really do live in some kind of fantasy land.
