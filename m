From: John Heffner <jheffner@psc.edu>
Subject: Re: TSO and MSS
Date: Wed, 29 Sep 2004 18:51:36 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.NEB.4.33.0409291848350.3434-100000@dexter.psc.edu>
References: <20040929154645.4e8987d2.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20040929154645.4e8987d2.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 29 Sep 2004, David S. Miller wrote:

> If you are on ethernet using different MTU's, shouldn't you be
> getting ICMP messages back when trying to communicate with that
> host which will decrease the PMTU of the path?  TCP's MSS is
> determined in terms of this, so I can't see what the issue is.

Unfortunately no.  If there's no router in between, the frame gets smashed
and no ICMP is generated.  Proper communication relies on honoring the MSS
value for directly connected machines.

Regardless, it is probably a good idea to honor the MSS value anyway,
because I think you're violating the TCP spec otherwise.

  -John
