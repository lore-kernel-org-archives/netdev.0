From: Andi Kleen <ak@suse.de>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Fri, 1 Oct 2004 12:23:06 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041001102306.GA4898@wotan.suse.de>
References: <20040929162923.796d142e.davem@davemloft.net> <Pine.NEB.4.33.0409291945100.3434-100000@dexter.psc.edu> <20040929170310.46c58095.davem@davemloft.net> <20040930001007.GB10496@gondor.apana.org.au> <20040930173439.3e0d2799.davem@davemloft.net> <20040930181248.48185e41.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, jheffner@psc.edu, ak@suse.de, niv@us.ibm.com,
        andy.grover@gmail.com, anton@samba.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040930181248.48185e41.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> With such small receive buffers, netperf simply can't clear
> the receive queue fast enough when a burst of TSO created
> frames come in.

I increased the receive buffers on the target and the difference
between TSO and non TSO is much less now (only 5MB/s instead of 20MB/s)

Your theory seems to make some sense.

-Andi
