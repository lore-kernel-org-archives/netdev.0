From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [ofa-general] Re: [PATCH RFC] RDMA/CMA: Allocate PS_TCP ports
	from the host TCP port space.
Date: Fri, 17 Aug 2007 12:52:39 -0700
Message-ID: <adaodh6x7js.fsf@cisco.com>
References: <46C310E1.7020503@opengridcomputing.com>
	<46C3B5EF.5060409@garzik.org>
	<1187271791.4685.9.camel@trinity.ogc.int>
	<20070816.141751.115907875.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	general@lists.openfabrics.org
To: David Miller <davem@davemloft.net>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070816.141751.115907875.davem@davemloft.net> (David Miller's
	message of "Thu, 16 Aug 2007 14:17:51 -0700 (PDT)")
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

 > > Isn't RDMA _part_ of the "software net stack" within Linux?

 > It very much is not so.

This is just nit-picking.  You can draw the boundary of the "software
net stack" wherever you want, but I think Sean's point was just that
RDMA drivers already are part of Linux, and we all want them to get
better.

 > When using RDMA you lose the capability to do packet shaping,
 > classification, and all the other wonderful networking facilities
 > you've grown to love and use over the years.

Same thing with TSO and LRO and who knows what else.  I know you're
going to make a distinction between "stateless" and "stateful"
offloads, but really it's just an arbitrary distinction between things
you like and things you don't.

 > Imagine if you didn't know any of this, you purchase and begin to
 > deploy a huge piece of RDMA infrastructure, you then get the mandate
 > from IT that you need to add firewalling on the RDMA connections at
 > the host level, and "oh shit" you can't?

It's ironic that you bring up firewalling.  I've had vendors of iWARP
hardware tell me they would *love* to work with the community to make
firewalling work better for RDMA connections.  But instead we get the
catch-22 of your changing arguments -- first, you won't even consider
changes that might help RDMA work better in the name of
maintainability; then you have to protect poor, ignorant users from
accidentally using RDMA because of some problem or another; and then
when someone tries to fix some of the problems you mention, it's back
to step one.

Obviously some decisions have been prejudged here, so I guess this
moves to the realm of politics.  I have plenty of interesting
technical stuff, so I'll leave it to the people with a horse in the
race to find ways to twist your arm.

 - R.
