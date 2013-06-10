From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v10 net-next 5/6] ixgbe: add support for ndo_ll_poll
Date: Mon, 10 Jun 2013 07:59:26 -0700
Message-ID: <1370876366.3252.6.camel@edumazet-glaptop>
References: <20130610083929.6955.87206.stgit@ladj378.jer.intel.com>
	 <20130610084020.6955.48255.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Willem de Bruijn <willemb@google.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Andi Kleen <andi@firstfloor.org>, HPA <hpa@zytor.com>,
	Eilon Greenstien <eilong@broadcom.com>,
	Or Gerlitz <or.gerlitz@gmail.com>,
	Amir Vadai <amirv@mellanox.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130610084020.6955.48255.stgit@ladj378.jer.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-06-10 at 11:40 +0300, Eliezer Tamir wrote:
> Add the ixgbe driver code implementing ndo_ll_poll.
> Adds ndo_ll_poll method and locking between it and the napi poll.
> When receiving a packet we use skb_mark_ll to record the napi it came from.
> Add each napi to the napi_hash right after netif_napi_add().
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Eliezer Tamir <eliezer.tamir@linux.intel.com>
> ---

Reviewed-by: Eric Dumazet <edumazet@google.com>
