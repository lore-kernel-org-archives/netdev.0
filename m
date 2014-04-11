From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH 0/3] mvneta: software TSO implementation
Date: Fri, 11 Apr 2014 21:43:39 +0200
Message-ID: <20140411194339.GA6758@1wt.eu>
References: <1397170682-19138-1-git-send-email-ezequiel.garcia@free-electrons.com> <20140410.205128.1312451576920196881.davem@davemloft.net> <1397178150.16584.53.camel@edumazet-glaptop2.roam.corp.google.com> <20140411054847.GE30855@1wt.eu> <20140411190827.GC19199@arch.cereza>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	thomas.petazzoni@free-electrons.com,
	gregory.clement@free-electrons.com, simon.guinot@sequanux.org,
	tawfik@marvell.com, alior@marvell.com
To: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:4133 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750735AbaDKTnr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Apr 2014 15:43:47 -0400
Content-Disposition: inline
In-Reply-To: <20140411190827.GC19199@arch.cereza>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 11, 2014 at 04:08:27PM -0300, Ezequiel Garcia wrote:
> On Apr 11, Willy Tarreau wrote:
> > On Thu, Apr 10, 2014 at 06:02:30PM -0700, Eric Dumazet wrote:
> > > On Thu, 2014-04-10 at 20:51 -0400, David Miller wrote:
> > > > This is not really driver specific code.
> > > > 
> > > > Please create an appropriate abstraction, and put this code in a
> > > > common place so that any driver can do this.
> > > > 
> > > > Thanks.
> > > 
> > > Note a prior implementation existed in
> > > 
> > > drivers/net/ethernet/tile/tilegx.c
> > > 
> > > Note sure how it can be properly factorized, but worth trying .
> > 
> > I also tried to find how to do this for mv643xx_eth a few years ago
> > 
> [..]
> 
> Can you share *any* code about this attempt on mv643xx_eth? It would be
> helpful to see other TSO cases, to have more examples in order to come
> up with a proper abstraction.

Unfortunately no. I remember that I picked the equivalent code from
mv_eth in the kirkwood's LSP and tried to adapt it to the mainline
driver, but unfortunately by then I didn't exactly understand well
what the driver was doing despite Eric explaining me a few things
about GSO and segmentation. Too many things were obscure to me and
I had to give up. The only vague memories I have are that this NIC
doesn't support Tx csum on VLANs nor IPv6. That's about all, I regret.

By the way, I could be wrong but I also have some memories about this
in the myri10ge driver. I recall something like it using software TSO
for VLANs or IPv6 or a combination of both, I don't exactly remember.
It's also possible that it depends on the firmware versions. Anyway the
driver is clean and well commented, it's easier to read than average.

Hoping this helps,
Willy
