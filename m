From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC/PATCH] "strict" ipv4 reassembly
Date: Tue, 17 May 2005 10:49:47 -0700 (PDT)
Message-ID: <20050517.104947.112621738.davem@davemloft.net>
References: <Pine.LNX.4.61.0505170914130.29021@linux.site>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: akepner@sgi.com
In-Reply-To: <Pine.LNX.4.61.0505170914130.29021@linux.site>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Arthur Kepner <akepner@sgi.com>
Date: Tue, 17 May 2005 09:18:26 -0700 (PDT)

>   1) Fragments must arrive in order (or in reverse order) -
>      out of order fragments are dropped. 

Even the most simplistic flow over the real internet
can get slight packet reordering.

Heck, reordering happens on SMP on any network.

IP is supposed to be resilient to side effects of network
topology, and one such common side effect is packet reordering.
It's common, it's fine, and the networking stack deals with it
gracefully.  Strict reassembly does not.

Sure it's off by default, but isn't it a better idea
to use NFS over TCP instead?

Decreasing ipfrag_time is also not an option, because then
you break fragmentation for packet radio folks :-)
