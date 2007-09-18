From: Roland Dreier <rdreier@cisco.com>
Subject: [ofa-general] Re: [PATCH net-2.6.24] Fix refcounting problem with
	netif_rx_reschedule()
Date: Tue, 18 Sep 2007 15:46:36 -0700
Message-ID: <adaodfzk2wj.fsf@cisco.com>
References: <20070918111803.1769.60619.sendpatchset@localhost.localdomain>
	<adawsunkg8i.fsf@cisco.com>
	<20070918.131505.91210517.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, general@lists.openfabrics.org
To: David Miller <davem@davemloft.net>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070918.131505.91210517.davem@davemloft.net> (David Miller's
	message of "Tue, 18 Sep 2007 13:15:05 -0700 (PDT)")
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

 > Further complicating things is that you need to setup a ppc32
 > cross-build environment to even build test a conversion, and I'm not
 > comfortable doing the surgery until I can test build the thing.

OK, I actually have a system with a ppc 440 SoC that uses this driver,
so I'll try to get things to the stage where I can boot net-2.6.24 on
it and see if I can get the driver working...
