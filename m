From: Andi Kleen <ak@suse.de>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Fri, 1 Oct 2004 12:35:54 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041001103554.GB4898@wotan.suse.de>
References: <20040929162923.796d142e.davem@davemloft.net> <Pine.NEB.4.33.0409291945100.3434-100000@dexter.psc.edu> <20040929170310.46c58095.davem@davemloft.net> <20040930001007.GB10496@gondor.apana.org.au> <20040930173439.3e0d2799.davem@davemloft.net> <20040930181248.48185e41.davem@davemloft.net> <20040930204005.69115c0e.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, jheffner@psc.edu, ak@suse.de, niv@us.ibm.com,
        andy.grover@gmail.com, anton@samba.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040930204005.69115c0e.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> How do things look for you with this change Andi?
> If things are still out of whack, play around with
> different values of /proc/sys/net/ipv4/tcp_tso_win_divisor

Still slower, like previously reported. But I tried tweaking
the sysctl now. Result is that 2 is pretty good (only 3MB/s) 
slower and >20 is also pretty good (2MB/s slower). Everything
inbetween is a lot slower, varying a bit. I wasn't able to find a setting
that gave the same results as TSO off though, although the
difference is not that dramatic anymore.

-Andi
