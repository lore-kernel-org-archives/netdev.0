From: John Heffner <jheffner@psc.edu>
Subject: Re: Current 2.6.x TSO state
Date: Fri, 1 Oct 2004 16:33:33 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.NEB.4.33.0410011630370.23725-100000@dexter.psc.edu>
References: <20041001200102.GB23046@wotan.suse.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@oss.sgi.com>,
        <herbert@gondor.apana.org.au>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20041001200102.GB23046@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 1 Oct 2004, Andi Kleen wrote:

> > As mentioned, the TCP receive buffer auto-tuning takes care
> > of all of this in 2.6.6 and later.  It's just 2.6.5 doesn't
> > have John Heffner's auto-tuning code which is why your test
> > case is so stuck in the mud.
> >
> > Also, the stretch ACK's are quite normal.  If the receiver can't
> > advertize a larger window, we won't spit out an ACK until
> > the ack timeout.
>
> Ok, but why is the TSO case still slower?

Because with TSO enabled, you get bigger back-to-back bursts during which
the receiving app can't run.

  -John
