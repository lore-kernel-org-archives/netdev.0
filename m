From: Andi Kleen <ak@suse.de>
Subject: Re: [2.6.0-test8/9] ethertap oops
Date: Mon, 27 Oct 2003 13:26:35 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031027122635.GB16013__12497.4818937064$1067271772@wotan.suse.de>
References: <L1fo.3gb.9@gated-at.bofh.it> <m3ekwz7h3z.fsf@averell.firstfloor.org> <20031026234828.2cb1f746.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@muc.de>, simon.roscic@chello.at,
   linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20031026234828.2cb1f746.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Oct 26, 2003 at 11:48:28PM -0800, David S. Miller wrote:
> On Sun, 26 Oct 2003 23:45:52 +0100
> Andi Kleen <ak@muc.de> wrote:
> 
> > diff -u linux-2.6.0test7mm1-averell/drivers/net/ethertap.c-o linux-2.6.0test7mm1-averell/drivers/net/ethertap.c
> > --- linux-2.6.0test7mm1-averell/drivers/net/ethertap.c-o	2003-09-11 04:12:33.000000000 +0200
> > +++ linux-2.6.0test7mm1-averell/drivers/net/ethertap.c	2003-10-26 23:41:17.000000000 +0100
> 
> This part looks good, applied.

I don't know if it actually fixed the bug, I did not test it
(sorry, should have stated that in the original mail)
But at least it should printk now instead of crashing.

-Andi
