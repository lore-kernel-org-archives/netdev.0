From: Roland Dreier <rdreier@cisco.com>
Subject: Re: Dropping NETIF_F_SG since no checksum feature.
Date: Tue, 10 Oct 2006 17:15:26 -0700
Message-ID: <adavemrbtcx.fsf@cisco.com>
References: <20061010104315.61540986@freekitty>
	<20061011001338.GA30093@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, openib-general@openib.org,
	Roland Dreier <rolandd@cisco.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-4.cisco.com ([171.68.10.86]:63916 "EHLO
	sj-iport-4.cisco.com") by vger.kernel.org with ESMTP
	id S932168AbWJKAPc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Oct 2006 20:15:32 -0400
To: "Michael S. Tsirkin" <mst@mellanox.co.il>
In-Reply-To: <20061011001338.GA30093@mellanox.co.il> (Michael S. Tsirkin's message of "Wed, 11 Oct 2006 02:13:38 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

    Michael> Maybe I can patch linux to allow SG without checksum?
    Michael> Dave, maybe you could drop a hint or two on whether this
    Michael> is worthwhile and what are the issues that need
    Michael> addressing to make this work?

What do you really gain by allowing SG without checksum?  Someone has
to do the checksum anyway, so I don't see that much difference between
doing it in the networking core before passing the data to/from the
driver, or down in the driver itself.

 - R.
