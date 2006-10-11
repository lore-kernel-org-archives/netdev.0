From: "Michael S. Tsirkin" <mst@mellanox.co.il>
Subject: Re: Dropping NETIF_F_SG since no checksum feature.
Date: Wed, 11 Oct 2006 02:26:56 +0200
Message-ID: <20061011002656.GB30093@mellanox.co.il>
References: <adavemrbtcx.fsf@cisco.com>
Reply-To: "Michael S. Tsirkin" <mst@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, openib-general@openib.org,
	Roland Dreier <rolandd@cisco.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030724AbWJKA1X@vger.kernel.org>
To: Roland Dreier <rdreier@cisco.com>
Content-Disposition: inline
In-Reply-To: <adavemrbtcx.fsf@cisco.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting r. Roland Dreier <rdreier@cisco.com>:
> Subject: Re: Dropping NETIF_F_SG since no checksum feature.
> 
>     Michael> Maybe I can patch linux to allow SG without checksum?
>     Michael> Dave, maybe you could drop a hint or two on whether this
>     Michael> is worthwhile and what are the issues that need
>     Michael> addressing to make this work?
> 
> What do you really gain by allowing SG without checksum?  Someone has
> to do the checksum anyway, so I don't see that much difference between
> doing it in the networking core before passing the data to/from the
> driver, or down in the driver itself.

My guess was, an extra pass over data is likely to be expensive - dirtying the
cache if nothing else. But I do plan to measure that, and see.

-- 
MST
