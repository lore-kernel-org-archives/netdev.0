From: "David S. Miller" <davem@davemloft.net>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Thu, 30 Sep 2004 13:23:21 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040930132321.523c9490.davem@davemloft.net>
References: <Pine.NEB.4.33.0409292008110.3434-100000@dexter.psc.edu>
	<Pine.NEB.4.33.0409301320510.13549-100000@dexter.psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, niv@us.ibm.com, herbert@gondor.apana.org.au,
        andy.grover@gmail.com, anton@samba.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: John Heffner <jheffner@psc.edu>
In-Reply-To: <Pine.NEB.4.33.0409301320510.13549-100000@dexter.psc.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 30 Sep 2004 13:25:46 -0400 (EDT)
John Heffner <jheffner@psc.edu> wrote:

> On Wed, 29 Sep 2004, John Heffner wrote:
> 
> > On Wed, 29 Sep 2004, John Heffner wrote:
> >
> > > Using iperf, I'm getting ~ the same speed to a slow p3 receiver (680
> > > Mbits) with TSO on or off right now.  Haven't tried netperf.
> >
> > Netperf does not work well for me (350 Mbits).  Something to investigate.
> 
> I tried again, and it does not even work this well.  The connection hangs
> at the end in state FIN_WAIT1 with 101361 bytes in the Send-Q.  It seems
> that the whole interface dies.  (Maybe it's sending something invalid to
> the TSO engine?)  When I bring the interface down then back up again, the
> connection terminates normally.
> 
> Don't have this problem with iperf, strange.

Even stranger is that with current netperf tg3-->tg3 works perfectly fine
for me with TSO enabled.  I'm getting clean 700Mbit transfers through
my D-Link DGS-1008T switch as long as netperf doesn't do something silly
like use tiny send/receiver buffers.

I've never had a transfer stall either.

Please help debug this John since I'm not seeing this here.
