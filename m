From: "Michael S. Tsirkin" <mst@mellanox.co.il>
Subject: Re: RFC: move SDP from AF_INET_SDP to IPPROTO_SDP
Date: Mon, 6 Mar 2006 22:16:03 +0200
Message-ID: <20060306201603.GA17048@mellanox.co.il>
References: <20060306190636.GA14849@mellanox.co.il> <OFB3CB1E4D.355F7555-ON88257129.006C1001-88257129.006C836D@us.ibm.com>
Reply-To: "Michael S. Tsirkin" <mst@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751360AbWCFUPz@vger.kernel.org>
To: David Stevens <dlstevens@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <OFB3CB1E4D.355F7555-ON88257129.006C1001-88257129.006C836D@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting r. David Stevens <dlstevens@us.ibm.com>:
> Subject: Re: RFC: move SDP from AF_INET_SDP to IPPROTO_SDP
> 
> I don't know any details about SDP, but if there are no differences at the
> protocol layer, then neither the address family nor the protocol is
> appropriate. If it's just an API change, the socket type is the right
> selector. So, maybe SOCK_DIRECT to go along with SOCK_STREAM,
> SOCK_DGRAM, etc.

No, the API SDP implements is the regular SOCK_STREAM semantics.

The difference is in the way connections are established with
infiniband connection management messages, and data is transferred
with infiniband reliable connection send messages.

-- 
Michael S. Tsirkin
Staff Engineer, Mellanox Technologies
