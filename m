From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] NETIF_F_LLTX for devices 2
Date: Sun, 12 Sep 2004 05:57:30 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040912095730.GA11484@havoc.gtf.org>
References: <20040908065152.GC27886@wotan.suse.de> <E1C4wYe-0005qT-00@gondolin.me.apana.org.au> <20040908072408.GI27886@wotan.suse.de> <1094629677.1089.155.camel@jzny.localdomain> <20040908134713.1bcd46d3.davem@davemloft.net> <1094823215.1121.129.camel@jzny.localdomain> <20040911142116.GL4431@wotan.suse.de> <1094933731.2343.109.camel@jzny.localdomain> <20040911174535.2acbb957.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, ak@suse.de, herbert@gondor.apana.org.au,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040911174535.2acbb957.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Sep 11, 2004 at 05:45:35PM -0700, David S. Miller wrote:
> I think Andi made the right choice for his implementation.
> And frankly I don't what is worrying about the
> "-1" return value, it can occur in only one spot in a very
> specific controlled case and it's behavior is incredibly well
> defined (if not by accurate comments then by the code itself :-)

Not commenting on the overall issue, but just the return code:

We already have net drivers getting the current TWO return codes wrong.
Adding one more -magic number- to the mix is just plain silly.

1. Add constants
2. Add clear, unambiguous documentation describing all three return codes
3. (janitor) use constants

Lacking #1 and #2 are design flaws that ignore existing problems,
and create new ones.  Luckily #1 and #2 are simple, human-friendly
fixes.

	Jeff
