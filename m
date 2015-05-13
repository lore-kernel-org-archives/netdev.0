From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net-next 2/2] rocker: mark parameters and local variables
 as const
Date: Wed, 13 May 2015 15:37:13 +0900
Message-ID: <20150513063713.GA23718@verge.net.au>
References: <1431496349-14833-1-git-send-email-simon.horman@netronome.com>
 <1431496349-14833-3-git-send-email-simon.horman@netronome.com>
 <CAE4R7bD+0q9pcNGA2swPQ54JWxMsDB15p=bdkeqaiL5=niL9RQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Simon Horman <simon.horman@netronome.com>,
	Jiri Pirko <jiri@resnulli.us>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:49699 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752119AbbEMGhQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 02:37:16 -0400
Content-Disposition: inline
In-Reply-To: <CAE4R7bD+0q9pcNGA2swPQ54JWxMsDB15p=bdkeqaiL5=niL9RQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 12, 2015 at 11:25:47PM -0700, Scott Feldman wrote:
> On Tue, May 12, 2015 at 10:52 PM, Simon Horman
> <simon.horman@netronome.com> wrote:
> > Mark parameters and local variables as const where possible.
> >
> > Signed-off-by: Simon Horman <simon.horman@netronome.com>
> > ---
> >  drivers/net/ethernet/rocker/rocker.c | 258 ++++++++++++++++++-----------------
> >  1 file changed, 136 insertions(+), 122 deletions(-)
> >
> 
> [cut]
> 
> > @@ -4833,7 +4847,7 @@ static int rocker_port_poll_rx(struct napi_struct *napi, int budget)
> >
> >  static void rocker_carrier_init(struct rocker_port *rocker_port)
> 
> Why are some left un-const, like above?

For some reason I didn't address the PCI driver ops.
I'll do another pass.
