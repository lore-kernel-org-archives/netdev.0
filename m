From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC] Replacing qdisc tc_stats with generic statistics to make
 it extendable
Date: Wed, 6 Oct 2004 10:41:43 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041006104143.0d5cbc81.davem@davemloft.net>
References: <20041003213124.GG14344@postel.suug.ch>
	<20041003213954.GI14344@postel.suug.ch>
	<20041003161436.50293f9a.davem@davemloft.net>
	<20041003235737.GO14344@postel.suug.ch>
	<20041005140304.6d0d5f02.davem@davemloft.net>
	<20041005222149.GA17186@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041005222149.GA17186@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 6 Oct 2004 00:21:49 +0200
Thomas Graf <tgraf@suug.ch> wrote:

> Since this is pretty major and will touch a lot of code I'd be interested
> if this is the right way to go and how to do it to make patch submission
> as easy as possible.
> Here would be my scenario on howto do it in several steps not breaking
> anything in between:
> Step 1: Use new generic networking statistics, update all qdiscs and
>         switch to new estimator. Doesn't break anything but must be
>         atomic.
> Step 2-N: Add dump_stats and update qdiscs one after each other.
> 
> Thoughts?

This sounds fine to me.  Don't be concerned about breaking binary-only
qdiscs :-)
