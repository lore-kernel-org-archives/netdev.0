From: KOVACS Krisztian <hidden@sch.bme.hu>
Subject: Re: [net-next PATCH 06/16] Handle TCP SYN+ACK/ACK/RST transparency
Date: Wed, 1 Oct 2008 16:46:22 +0200
Message-ID: <20081001144622.GC25672@sch.bme.hu>
References: <20081001142431.4893.48078.stgit@este> <20081001142431.4893.64737.stgit@este> <20081001.074250.261632354.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hidden@sch.bme.hu, kaber@trash.net, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081001.074250.261632354.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Wed, Oct 01, 2008 at 07:42:50AM -0700, David Miller wrote:
> From: KOVACS Krisztian <hidden@sch.bme.hu>
> Date: Wed, 01 Oct 2008 16:24:31 +0200
> 
> > The TCP stack sends out SYN+ACK/ACK/RST reply packets in response to
> > incoming packets. The non-local source address check on output bites
> > us again, as replies for transparently redirected traffic won't have a
> > chance to leave the node.
> > 
> > This patch selectively sets the FLOWI_FLAG_ANYSRC flag when doing
> > the route lookup for those replies. Transparent replies are enabled if
> > the listening socket has the transparent socket flag set.
> > 
> > Signed-off-by: KOVACS Krisztian <hidden@sch.bme.hu>
> 
> I had to make some modifications to make this build.
> 
> I took two include/net/ip.h modifications from patch 7:
> 
> 1) Adding flags to ip_reply_arg struct
> 2) definition of IP_REPLY_ARG_NOSRCCHECK
> 
> and the result is included below and added to net-next-2.6

Oops, my fault, sorry. Should have been more careful when juggling around
with patches yesterday...

-- 
KOVACS Krisztian
