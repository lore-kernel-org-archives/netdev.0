From: "David S. Miller" <davem@davemloft.net>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Thu, 30 Sep 2004 17:34:39 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040930173439.3e0d2799.davem@davemloft.net>
References: <20040929162923.796d142e.davem@davemloft.net>
	<Pine.NEB.4.33.0409291945100.3434-100000@dexter.psc.edu>
	<20040929170310.46c58095.davem@davemloft.net>
	<20040930001007.GB10496@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jheffner@psc.edu, ak@suse.de, niv@us.ibm.com, andy.grover@gmail.com,
        anton@samba.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040930001007.GB10496@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


So I was wondering what in 2.6.5 vs. current 2.6.x TCP could
be tripping up Andi's setup and I think I just found it.

If I disable /proc/sys/net/tcp_moderate_rcvbuf performance
goes down from ~634Mbit/sec to ~495Mbit/sec.

Andi, I know you said that with TSO disabled things go 
more smoothly.  But could you try upping the TCP socket
receive buffer sizes on the 2.6.5 box to see if that gives
you the performance back with TSO enabled?
