From: John Heffner <jheffner@psc.edu>
Subject: Re: [PATCH] Too aggressive cwnd backoff
Date: Thu, 7 Apr 2005 14:37:08 -0400 (EDT)
Message-ID: <Pine.LNX.4.58.0504071435450.17545@dexter.psc.edu>
References: <20050407164146.GA6479@ev-en.org> <20050407101653.2cc68db1@dxpl.pdx.osdl.net>
 <42557895.8040004@ev-en.org> <20050407113121.31b71a94.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Baruch Even <baruch@ev-en.org>, shemminger@osdl.org, netdev@oss.sgi.com,
        werner@almesberger.net
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050407113121.31b71a94.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 7 Apr 2005, David S. Miller wrote:

> On Thu, 07 Apr 2005 19:14:45 +0100
> Baruch Even <baruch@ev-en.org> wrote:
>
> > > Going back to the pre-westwood code in BK, the /2 is still there.
> >
> > This wasn't there in 2.4.23 on which on the original work of H-TCP was
> > done.
>
> Not true, that division by 2 is in the 2.4.23 sources, I just
> checked.
>
> It is there as far back as BK logs go in both the 2.4.x and 2.6.x
> trees.
>
> Perhaps the WEB100 guys patched that test, I bet that's why you don't
> remember it being in 2.4.23

This test looks correct to me.  (We never touched it.)  It is the bounding
parameter specified in rate halving.  If you actually get down that far,
then rate halving is getting confused, though.

  -John
