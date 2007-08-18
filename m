From: David Miller <davem@davemloft.net>
Subject: Re: [ofa-general] Re: [PATCH RFC] RDMA/CMA: Allocate PS_TCP ports
	from the host TCP port space.
Date: Fri, 17 Aug 2007 17:00:33 -0700 (PDT)
Message-ID: <20070817.170033.63993876.davem@davemloft.net>
References: <adaodh6x7js.fsf@cisco.com>
	<20070817.142756.65194845.davem@davemloft.net>
	<adafy2hyc04.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	general@lists.openfabrics.org
To: rdreier@cisco.com
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <adafy2hyc04.fsf@cisco.com>
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

From: Roland Dreier <rdreier@cisco.com>
Date: Fri, 17 Aug 2007 16:31:07 -0700

>  > >  > When using RDMA you lose the capability to do packet shaping,
>  > >  > classification, and all the other wonderful networking facilities
>  > >  > you've grown to love and use over the years.
>  > > 
>  > > Same thing with TSO and LRO and who knows what else.
>  > 
>  > Not true at all.  Full classification and filtering still is usable
>  > with TSO and LRO.
> 
> Well, obviously with TSO and LRO the packets that the stack sends or
> receives are not the same as what's on the wire.  Whether that breaks
> your wonderful networking facilities or not depends on the specifics
> of the particular facility I guess -- for example shaping is clearly
> broken by TSO.  (And people can wonder what the packet trains TSO
> creates do to congestion control on the internet, but the netdev crowd
> has already decided that TSO is "good" and RDMA is "bad")

This is also a series of falsehoods.  All packet filtering,
queue management, and packet scheduling facilities work perfectly
fine and as designed with both LRO and TSO.

When problems come up, they are bugs, and we fix them.

Please stop spreading this FUD about TSO and LRO.

The fact is that RDMA bypasses the whole stack so that supporting
these facilities is not even _POSSIBLE_.  With stateless offloads it
is possible to support all of these facilities, and we do.
