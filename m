From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v6 net-next 1/5] net: add napi_id and hash
Date: Wed, 29 May 2013 05:56:41 -0700
Message-ID: <1369832201.5109.8.camel@edumazet-glaptop>
References: <20130529063916.27486.3841.stgit@ladj378.jer.intel.com>
	 <20130529063925.27486.46649.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Willem de Bruijn <willemb@google.com>,
	Andi Kleen <andi@firstfloor.org>, HPA <hpa@zytor.com>,
	Eilon Greenstien <eilong@broadcom.com>,
	Or Gerlitz <or.gerlitz@gmail.com>,
	Alex Rosenbaum <alexr@mellanox.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130529063925.27486.46649.stgit@ladj378.jer.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-05-29 at 09:39 +0300, Eliezer Tamir wrote:
> Adds a napi_id and a hashing mechanism to lookup a napi by id.
> This will be used by subsequent patches to implement low latency
> Ethernet device polling.
> Based on a code sample by Eric Dumazet.
> 
> Signed-off-by: Eliezer Tamir <eliezer.tamir@linux.intel.com>
> ---

OK this looks good enough for inclusion.

If a v7 ever is submitted, please add a 'static' for

static DEFINE_SPINLOCK(napi_hash_lock);
static unsigned int napi_gen_id;
static DEFINE_HASHTABLE(napi_hash, 8);

If David chose to apply v6, I'll submit a patch for this.

Signed-off-by: Eric Dumazet <edumazet@google.com>
