From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC][PATCH 2/2] ip multipath, bk head (EXPERIMENTAL)
Date: Mon, 13 Sep 2004 22:42:32 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040913224232.4b979c7d.davem@davemloft.net>
References: <41457848.6040808@de.ibm.com>
	<1095129624.1060.45.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: lkml@einar-lueck.de, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1095129624.1060.45.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 13 Sep 2004 22:40:24 -0400
jamal <hadi@cyberus.ca> wrote:

> As long as whatever arrangement ensures that no packet reordering
> happens, should be sane. Yes, current scheme is broken in some ways (but
> guarantees packet ordering within a flow).

I think his changes ensure this as well, at least for local system
sockets.  You'll only get a new hop each time a route lookup is
performed, which is only done once per socket unless the path
becomes "sick" and TCP decides to try and do a relookup of the
destination.

I'm kind of ambivalent about these changes.  I definitely like the
first patch which cleans up those huge functions in route.c :-)
But there are things I like about the current behavior, although I
understand why people want things to work the way Einar is changing
it to.
