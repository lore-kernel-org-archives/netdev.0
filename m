From: John Heffner <jheffner@psc.edu>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Wed, 29 Sep 2004 19:51:21 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.NEB.4.33.0409291945100.3434-100000@dexter.psc.edu>
References: <20040929162923.796d142e.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andi Kleen <ak@suse.de>, <niv@us.ibm.com>, <herbert@gondor.apana.org.au>,
        <andy.grover@gmail.com>, <anton@samba.org>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20040929162923.796d142e.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 29 Sep 2004, David S. Miller wrote:

> Let me know if this cures the issue, and if it does we can
> move back to Andi's performance issue and the MSS stuff
> John Heffner just discovered.

Seems to work for me.

Using iperf, I'm getting ~ the same speed to a slow p3 receiver (680
Mbits) with TSO on or off right now.  Haven't tried netperf.

  -John
