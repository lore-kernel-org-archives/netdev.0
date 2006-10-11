From: Roland Dreier <rdreier@cisco.com>
Subject: Re: Dropping NETIF_F_SG since no checksum feature.
Date: Tue, 10 Oct 2006 20:49:09 -0700
Message-ID: <adafydvbjgq.fsf@cisco.com>
References: <adar6xfbk6d.fsf@cisco.com>
	<20061010.203624.91207079.davem@davemloft.net>
	<adak637bjs3.fsf@cisco.com>
	<20061010.204528.90823856.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mst@mellanox.co.il, shemminger@osdl.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	openib-general@openib.org, rolandd@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:60019 "EHLO
	sj-iport-5.cisco.com") by vger.kernel.org with ESMTP
	id S1030782AbWJKDtV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Oct 2006 23:49:21 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061010.204528.90823856.davem@davemloft.net> (David Miller's message of "Tue, 10 Oct 2006 20:45:28 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

    David> non-sendfile() paths will generate big packets just fine,
    David> as long as the application is providing that much data.

OK, cool.  Will the big packets be non-linear skbs?

Because then it would make sense for a device with a huge MTU to want
to accept them without linearizing them, even if it had to copy them
to checksum the data.  Otherwise with fragmented memory it would be
impossible to handle such big packets at all.

 - R.
