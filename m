From: Andi Kleen <ak@suse.de>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Thu, 23 Sep 2004 00:47:32 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040922224732.GD2619@wotan.suse.de>
References: <20040920063012.GL2825@krispykreme> <20040920203021.GD4242@wotan.suse.de> <20040921155835.18aee381.davem@davemloft.net> <20040922140000.GD27432@wotan.suse.de> <20040922111209.7887df53.davem@davemloft.net> <20040922195515.GA2619@wotan.suse.de> <c0a09e5c04092213126ba5f29d@mail.gmail.com> <20040922133906.7d57ef49.davem@davemloft.net> <20040922220628.GC2619@wotan.suse.de> <20040922152535.7bc81c8a.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>, andy.grover@gmail.com, anton@samba.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040922152535.7bc81c8a.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Sep 22, 2004 at 03:25:35PM -0700, David S. Miller wrote:
> On Thu, 23 Sep 2004 00:06:28 +0200
> Andi Kleen <ak@suse.de> wrote:
> 
> > > One thing that could be biting us is the nagle check which
> > > probably needs to be adjusted to use the standard MSS not
> > > the TSO one... perhaps play with this patch:
> > 
> > I tried it and it breaks the performance completely
> > (21MB/s) 
> 
> You said you were getting 22MB/sec before the change, right?

22-23MB/s, but not 21MB/s. Ok "breaks completely" was a bit of overstatement,
admitted.

-Andi
