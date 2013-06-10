From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v10 net-next 2/6] net: add low latency socket poll
Date: Mon, 10 Jun 2013 07:29:36 -0700
Message-ID: <1370874576.3252.3.camel@edumazet-glaptop>
References: <20130610083929.6955.87206.stgit@ladj378.jer.intel.com>
	 <20130610083950.6955.9813.stgit@ladj378.jer.intel.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f52.google.com ([74.125.83.52]:51823 "EHLO
	mail-ee0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751030Ab3FJO3m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jun 2013 10:29:42 -0400
In-Reply-To: <20130610083950.6955.9813.stgit@ladj378.jer.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-06-10 at 11:39 +0300, Eliezer Tamir wrote:
> Adds an ndo_ll_poll method and the code that supports it.
> This method can be used by low latency applications to busy-poll
> Ethernet device queues directly from the socket code.
> sysctl_net_ll_poll controls how many microseconds to poll.
> Default is zero (disabled).
> Individual protocol support will be added by subsequent patches.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Eliezer Tamir <eliezer.tamir@linux.intel.com>
> ---
> 
>  Documentation/sysctl/net.txt |    7 ++
>  include/linux/netdevice.h    |    3 +
>  include/linux/skbuff.h       |    8 ++
>  include/net/ll_poll.h        |  148 ++++++++++++++++++++++++++++++++++++++++++
>  include/net/sock.h           |    4 +
>  include/uapi/linux/snmp.h    |    1 
>  net/Kconfig                  |   12 +++
>  net/core/skbuff.c            |    4 +
>  net/core/sock.c              |    6 ++
>  net/core/sysctl_net_core.c   |   10 +++
>  net/ipv4/proc.c              |    1 
>  net/socket.c                 |    6 ++
>  12 files changed, 208 insertions(+), 2 deletions(-)
>  create mode 100644 include/net/ll_poll.h

Acked-by: Eric Dumazet <edumazet@google.com>
