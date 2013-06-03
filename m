From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v8 net-next 1/7] net: add napi_id and hash
Date: Mon, 03 Jun 2013 05:58:14 -0700
Message-ID: <1370264294.24311.125.camel@edumazet-glaptop>
References: <20130603080107.18273.34279.stgit@ladj378.jer.intel.com>
	 <20130603080117.18273.68908.stgit@ladj378.jer.intel.com>
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
	Alex Rosenbaum <alexr@mellanox.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130603080117.18273.68908.stgit@ladj378.jer.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-06-03 at 11:01 +0300, Eliezer Tamir wrote:
> Adds a napi_id and a hashing mechanism to lookup a napi by id.
> This will be used by subsequent patches to implement low latency
> Ethernet device polling.
> Based on a code sample by Eric Dumazet.
> 
> Signed-off-by: Eliezer Tamir <eliezer.tamir@linux.intel.com>
> ---
> 
>  include/linux/netdevice.h |   29 ++++++++++++++++++++++
>  net/core/dev.c            |   59 +++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 88 insertions(+), 0 deletions(-)

Signed-off-by: Eric Dumazet <edumazet@google.com>
