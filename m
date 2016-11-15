From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH/RFC] ravb: Support 1Gbps on R-Car H3 ES1.1+ and R-Car M3-W
Date: Tue, 15 Nov 2016 18:53:54 +0100
Message-ID: <20161115175354.GA3979@verge.net.au>
References: <1477934018-13968-1-git-send-email-geert+renesas@glider.be>
 <20161031.132431.648834397805808388.davem@davemloft.net>
 <20161101093216.GE28143@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: geert+renesas@glider.be, sergei.shtylyov@cogentembedded.com,
        arnd@arndb.de, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161101093216.GE28143@verge.net.au>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 01, 2016 at 10:32:17AM +0100, Simon Horman wrote:
> On Mon, Oct 31, 2016 at 01:24:31PM -0400, David Miller wrote:
> > From: Geert Uytterhoeven <geert+renesas@glider.be>
> > Date: Mon, 31 Oct 2016 18:13:38 +0100
> > 
> > > The limitation to 10/100Mbit speeds on R-Car Gen3 is valid for R-Car H3
> > > ES1.0 only. Check for the exact SoC model to allow 1Gbps on newer
> > > revisions of R-Car H3, and on R-Car M3-W.
> > > 
> > > Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
> > > ---
> > > Tested on:
> > >   - r8a7795/salvator-x with R-Car H3 ES1.0 (limited to 100Mbps),
> > >   - r8a7795/salvator-x with R-Car H3 ES1.1 (1Gbps),
> > >   - r8a7796/salvator-x with R-Car M3-W ES1.0 (1Gbps).
> > > 
> > > This is marked as an RFC because it depends on:
> > >   A) the soc_device_match() infrastructure,
> > >   B) Renesas SoC core ESx.y handling.
> > > Hence I think the best merge strategy is to let this patch go in through
> > > Simon's Renesas tree.
> > > 
> > > David: If you agree, can you please provide your ack? Thanks!
> > 
> > Sure, no problem:
> > 
> > Acked-by: David S. Miller <davem@davemloft.net>
> 
> Thanks Dave.
> 
> Geert, please repost or otherwise ping me once the dependencies are in
> place and I should queue this up.

For the record, I have queued this up for v4.10.
