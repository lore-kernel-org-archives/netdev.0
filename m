From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 net-next 2/4] tcp: add TCP support for low latency
 receive poll.
Date: Mon, 20 May 2013 06:49:02 -0700
Message-ID: <1369057742.3301.168.camel@edumazet-glaptop>
References: <20130520101552.14133.45953.stgit@ladj378.jer.intel.com>
	 <20130520101612.14133.95780.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dave Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Willem de Bruijn <willemb@google.com>,
	Andi Kleen <andi@firstfloor.org>, HPA <hpa@zytor.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130520101612.14133.95780.stgit@ladj378.jer.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-05-20 at 13:16 +0300, Eliezer Tamir wrote:
>  
> +config INET_LL_TCP_POLL
> +	bool "Low Latency TCP Receive Poll"
> +	depends on INET_LL_RX_POLL
> +	default n
> +	---help---
> +	  TCP support for Low Latency TCP Queue Poll.
> +	  (For network cards that support this option.)
> +	  Add support to the TCP stack for direct polling of the network card.
> +
> +	  If unsure, say N.
> +

Oh well, code is small and already guarded by CONFIG_INET_LL_RX_POLL
