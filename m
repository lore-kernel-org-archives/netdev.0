From: "David S. Miller" <davem@davemloft.net>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Wed, 29 Sep 2004 12:56:44 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040929125644.40358b42.davem@davemloft.net>
References: <20040928223344.GC2975@wotan.suse.de>
	<Pine.NEB.4.33.0409282323220.27103-100000@dexter.psc.edu>
	<20040929090103.GB18671@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jheffner@psc.edu, ak@suse.de, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20040929090103.GB18671@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 29 Sep 2004 11:01:03 +0200
Andi Kleen <ak@suse.de> wrote:

> > Does this help?
> 
> Possible. I don't have any plans to change the receiver because
> it works well for most cases.
> 
> The problem must be still in the sender.

"Must"?  So you've proven that the ack-every-22 packets behavior
is due entirely to the sender?

If you put 2.6.9-current on both ends and this makes things go smoothly
that is an important data point and nobody else is seeing the behavior
you are at the moment.

Personally, all of my bets are on the 2.6.5 frankenstein kernel
as the culprit :-)
