From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Advice needed on IP-over-InfiniBand driver
Date: Sun, 19 Sep 2004 14:01:33 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040919140133.60ea3fb3.davem@davemloft.net>
References: <52fz5esxx6.fsf@topspin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Roland Dreier <roland@topspin.com>
In-Reply-To: <52fz5esxx6.fsf@topspin.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


You probably want to be editing net/ipv4/arp.c and testing
it about Infiniband.  Keep neighbour entries in the unresolved
stated until both transitions are made:

1) obtain 20 byte address
2) get response from IB subnet manager

Only store the destination GID in the neighbour entry,
and only mark the neighbour entry as resolved once
#2 above completes successfully.
