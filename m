From: "David S. Miller" <davem@davemloft.net>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Wed, 29 Sep 2004 14:17:31 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040929141731.2685e561.davem@davemloft.net>
References: <20040928223344.GC2975@wotan.suse.de>
	<Pine.NEB.4.33.0409282323220.27103-100000@dexter.psc.edu>
	<20040929090103.GB18671@wotan.suse.de>
	<20040929125644.40358b42.davem@davemloft.net>
	<20040929225635.061f2405.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jheffner@psc.edu, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20040929225635.061f2405.ak@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 29 Sep 2004 22:56:35 +0200
Andi Kleen <ak@suse.de> wrote:

> Also the test that John wanted to diable has been in Linux practically
> forever (irc dates back to Eric Schenk's work in 2.0) 

Yes, but it could prove something about either the sender
or the receiver, namely that the receive window is not openning
up fast enough for some reason, thus delaying the ACKs.

> Part of the trace. It looks like the new kernel has really
> bad problems with acking.

It looks, again, like the receiver's window is not openning
up fast enough, which controls ACK response decisions, and
that is what jheffner's patch is supposed to verify.
