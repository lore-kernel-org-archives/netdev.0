From: John Heffner <jheffner@psc.edu>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Thu, 30 Sep 2004 13:25:46 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.NEB.4.33.0409301320510.13549-100000@dexter.psc.edu>
References: <Pine.NEB.4.33.0409292008110.3434-100000@dexter.psc.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andi Kleen <ak@suse.de>, <niv@us.ibm.com>, <herbert@gondor.apana.org.au>,
        <andy.grover@gmail.com>, <anton@samba.org>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <Pine.NEB.4.33.0409292008110.3434-100000@dexter.psc.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 29 Sep 2004, John Heffner wrote:

> On Wed, 29 Sep 2004, John Heffner wrote:
>
> > Using iperf, I'm getting ~ the same speed to a slow p3 receiver (680
> > Mbits) with TSO on or off right now.  Haven't tried netperf.
>
> Netperf does not work well for me (350 Mbits).  Something to investigate.

I tried again, and it does not even work this well.  The connection hangs
at the end in state FIN_WAIT1 with 101361 bytes in the Send-Q.  It seems
that the whole interface dies.  (Maybe it's sending something invalid to
the TSO engine?)  When I bring the interface down then back up again, the
connection terminates normally.

Don't have this problem with iperf, strange.

  -John
