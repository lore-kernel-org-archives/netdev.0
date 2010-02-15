From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 0/2] tun: linux socket filter support
Date: Mon, 15 Feb 2010 16:47:26 +0100
Message-ID: <201002151647.26532.arnd@arndb.de>
References: <20100214110051.GA30182@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Paul Moore <paul.moore@hp.com>,
	David Woodhouse <David.Woodhouse@intel.com>,
	Sridhar Samudrala <sri@us.ibm.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100214110051.GA30182@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 14 February 2010, Michael S. Tsirkin wrote:
> tun module already support RX filtering, however,
> this is limited to filtering by mac address.
> For virtio host, we also need filtering by vlan.
> 
> Rather than adding this directly, it seems cleaner
> to add generic socket filter support.

Great idea, I was wondering how to do vlan filtering
in macvtap with trunk mode. I guess it would be
straightforward to do the same patch in macvtap, right?

	Arnd
