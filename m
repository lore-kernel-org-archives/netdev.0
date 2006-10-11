From: Roland Dreier <rdreier@cisco.com>
Subject: Re: Dropping NETIF_F_SG since no checksum feature.
Date: Tue, 10 Oct 2006 20:33:46 -0700
Message-ID: <adar6xfbk6d.fsf@cisco.com>
References: <adavemrbtcx.fsf@cisco.com>
	<20061011002656.GB30093@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, openib-general@openib.org,
	Roland Dreier <rolandd@cisco.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:61786 "EHLO
	sj-iport-6.cisco.com") by vger.kernel.org with ESMTP
	id S1030499AbWJKDdt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Oct 2006 23:33:49 -0400
To: "Michael S. Tsirkin" <mst@mellanox.co.il>
In-Reply-To: <20061011002656.GB30093@mellanox.co.il> (Michael S. Tsirkin's message of "Wed, 11 Oct 2006 02:26:56 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

    Michael> My guess was, an extra pass over data is likely to be
    Michael> expensive - dirtying the cache if nothing else. But I do
    Michael> plan to measure that, and see.

I don't get it -- where's the extra pass?  If you can't compute the
checksum on the NIC then you have to compute sometime it on the CPU
before passing the data to the NIC.

 - R.
