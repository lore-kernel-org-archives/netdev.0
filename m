From: John Heffner <jheffner@psc.edu>
Subject: Re: A case AGAINST checksum offload
Date: Fri, 12 Nov 2004 19:36:35 -0500 (EST)
Message-ID: <Pine.LNX.4.58.0411121925070.8989@dexter.psc.edu>
References: <Pine.LNX.4.58.0411121644150.8989@dexter.psc.edu>
 <20041112154945.63da5103.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20041112154945.63da5103.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 12 Nov 2004, David S. Miller wrote:

> The data could just as easily be corrupted on the way to the CPU when
> doing a copy+checksum operation.  It's the same problem you say exists
> with your networking card case except the path of the corruption is
> RAM-->CPU instead of RAM-->PCI Controller-->Networking Card
>
> I really don't buy this. :-)

Sure.  But we can get a check on one point of failure nearly free.  I've
measured about a 1% difference in CPU use with checksum on vs. off at 1
gigabit.

Probably not a big deal (yeah, somethings buggy anyway and needs to be
fixed or replaced), but I thought it worth pointing out.

  -John
