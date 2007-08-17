From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [ofa-general] Re: [PATCH RFC] RDMA/CMA: Allocate PS_TCP ports
	from the host TCP port space.
Date: Fri, 17 Aug 2007 16:31:07 -0700
Message-ID: <adafy2hyc04.fsf@cisco.com>
References: <1187271791.4685.9.camel@trinity.ogc.int>
	<20070816.141751.115907875.davem@davemloft.net>
	<adaodh6x7js.fsf@cisco.com>
	<20070817.142756.65194845.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	general@lists.openfabrics.org
To: David Miller <davem@davemloft.net>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070817.142756.65194845.davem@davemloft.net> (David Miller's
	message of "Fri, 17 Aug 2007 14:27:56 -0700 (PDT)")
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

 > >  > When using RDMA you lose the capability to do packet shaping,
 > >  > classification, and all the other wonderful networking facilities
 > >  > you've grown to love and use over the years.
 > > 
 > > Same thing with TSO and LRO and who knows what else.
 > 
 > Not true at all.  Full classification and filtering still is usable
 > with TSO and LRO.

Well, obviously with TSO and LRO the packets that the stack sends or
receives are not the same as what's on the wire.  Whether that breaks
your wonderful networking facilities or not depends on the specifics
of the particular facility I guess -- for example shaping is clearly
broken by TSO.  (And people can wonder what the packet trains TSO
creates do to congestion control on the internet, but the netdev crowd
has already decided that TSO is "good" and RDMA is "bad")

 - R.
