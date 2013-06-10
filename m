From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v10 net-next 3/6] udp: add low latency socket poll
 support
Date: Mon, 10 Jun 2013 07:31:08 -0700
Message-ID: <1370874668.3252.4.camel@edumazet-glaptop>
References: <20130610083929.6955.87206.stgit@ladj378.jer.intel.com>
	 <20130610084000.6955.20487.stgit@ladj378.jer.intel.com>
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
In-Reply-To: <20130610084000.6955.20487.stgit@ladj378.jer.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-06-10 at 11:40 +0300, Eliezer Tamir wrote:
> Add upport for busy-polling on UDP sockets.
> In __udp[46]_lib_rcv add a call to sk_mark_ll() to copy the napi_id
> from the skb into the sk.
> This is done at the earliest possible moment, right after we identify
> which socket this skb is for.
> In __skb_recv_datagram When there is no data and the user
> tries to read we busy poll.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Eliezer Tamir <eliezer.tamir@linux.intel.com>
> ---
> 
>  net/core/datagram.c |    4 ++++
>  net/ipv4/udp.c      |    6 +++++-
>  net/ipv6/udp.c      |    6 +++++-
>  3 files changed, 14 insertions(+), 2 deletions(-)

Acked-by: Eric Dumazet <edumazet@google.com>
