From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 08/16] Port redirection support for TCP
Date: Wed, 01 Oct 2008 07:47:26 -0700 (PDT)
Message-ID: <20081001.074726.20974386.davem@davemloft.net>
References: <20081001142431.4893.48078.stgit@este>
	<20081001142431.4893.4942.stgit@este>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: hidden@sch.bme.hu
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20081001142431.4893.4942.stgit@este>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: KOVACS Krisztian <hidden@sch.bme.hu>
Date: Wed, 01 Oct 2008 16:24:31 +0200

> Current TCP code relies on the local port of the listening socket
> being the same as the destination address of the incoming
> connection. Port redirection used by many transparent proxying
> techniques obviously breaks this, so we have to store the original
> destination port address.
> 
> This patch extends struct inet_request_sock and stores the incoming
> destination port value there. It also modifies the handshake code to
> use that value as the source port when sending reply packets.
> 
> Signed-off-by: KOVACS Krisztian <hidden@sch.bme.hu>

Applied to net-next-2.6
