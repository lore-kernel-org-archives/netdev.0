From: Roland Dreier <roland@topspin.com>
Subject: Re: Advice needed on IP-over-InfiniBand driver
Date: Sun, 19 Sep 2004 21:42:59 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <523c1dsg8c.fsf@topspin.com>
References: <52fz5esxx6.fsf@topspin.com>
	<20040919140133.60ea3fb3.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20040919140133.60ea3fb3.davem@davemloft.net> (David S.
 Miller's message of "Sun, 19 Sep 2004 14:01:33 -0700")
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

    David> You probably want to be editing net/ipv4/arp.c and testing

"teaching" not "testing" I assume :)

    David> it about Infiniband.  Keep neighbour entries in the
    David> unresolved stated until both transitions are made:

    David> 1) obtain 20 byte address 2) get response from IB subnet
    David> manager

    David> Only store the destination GID in the neighbour entry, and
    David> only mark the neighbour entry as resolved once #2 above
    David> completes successfully.

Hmm... it looks like the place you're telling me to hook into is in
arp_process() right before the neigh state gets set to NUD_REACHABLE.
But where should I stick the path information that I get back from the
subnet manager once the query finishes?  And how does the path get
passed into the device driver to actually send an skb?

(Sorry to be so dense but I'm afraid my little brain needs things
broken down into bite-sized pieces...)

Thanks,
  Roland
