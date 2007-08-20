From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [ofa-general] Re: [PATCH RFC] RDMA/CMA: Allocate PS_TCPportsfrom
	the host TCP port space.
Date: 20 Aug 2007 20:10:56 +0200
Message-ID: <p73y7g6yt3j.fsf@bingen.suse.de>
References: <20070819.174017.77241227.davem@davemloft.net>
	<8A71B368A89016469F72CD08050AD334018E20BE@maui.asicdesigners.com>
	<20070820094317.GA14817@2ka.mipt.ru>
	<8A71B368A89016469F72CD08050AD334018E2115@maui.asicdesigners.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>, jeff@garzik.org,
	netdev@vger.kernel.org, rdreier@cisco.com,
	linux-kernel@vger.kernel.org, general@lists.openfabrics.org,
	David Miller <davem@davemloft.net>
To: "Felix Marti" <felix@chelsio.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <8A71B368A89016469F72CD08050AD334018E2115@maui.asicdesigners.com>
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

"Felix Marti" <felix@chelsio.com> writes:

> What I was referring to is that TSO(/LRO) have their own
> issues, some eluded to by Roland and me. In fact, customers working on
> the LSR couldn't use TSO due to the burstiness it introduces

That was in old kernels where TSO didn't honor the initial cwnd correctly, 
right? I assume it's long fixed.

If not please clarify what the problem was.

> have a look at graphics.
> Graphics used to be done by the host CPU and now we have dedicated
> graphics adapters that do a much better job...

Is your off load device as programable as a modern GPU?

> farfetched that offload devices can do a better job at a data-flow
> problem?

One big difference is that there is no potentially adverse and
always varying internet between the graphics card and your monitor.

-Andi
