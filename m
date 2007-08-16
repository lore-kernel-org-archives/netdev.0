From: David Miller <davem@davemloft.net>
Subject: Re: [ofa-general] Re: [PATCH RFC] RDMA/CMA: Allocate PS_TCP ports
	from the host TCP port space.
Date: Thu, 16 Aug 2007 14:17:51 -0700 (PDT)
Message-ID: <20070816.141751.115907875.davem@davemloft.net>
References: <46C310E1.7020503@opengridcomputing.com>
	<46C3B5EF.5060409@garzik.org>
	<1187271791.4685.9.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, rdreier@cisco.com,
	linux-kernel@vger.kernel.org, general@lists.openfabrics.org
To: tom@opengridcomputing.com
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <1187271791.4685.9.camel@trinity.ogc.int>
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

From: Tom Tucker <tom@opengridcomputing.com>
Date: Thu, 16 Aug 2007 08:43:11 -0500

> Isn't RDMA _part_ of the "software net stack" within Linux?

It very much is not so.

When using RDMA you lose the capability to do packet shaping,
classification, and all the other wonderful networking facilities
you've grown to love and use over the years.

I'm glad this is a surprise to you, because it illustrates the
point some of us keep trying to make about technologies like
this.

Imagine if you didn't know any of this, you purchase and begin to
deploy a huge piece of RDMA infrastructure, you then get the mandate
from IT that you need to add firewalling on the RDMA connections at
the host level, and "oh shit" you can't?

This is why none of us core networking developers like RDMA at all.
It's totally not integrated with the rest of the Linux stack and on
top of that it even gets in the way.  It's an abberation, an eye sore,
and a constant source of consternation.
