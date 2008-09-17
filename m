From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ipvs: change some __constant_htons() to htons()
Date: Wed, 17 Sep 2008 10:14:39 +1000
Message-ID: <20080917001436.GA15750@verge.net.au>
References: <48CFCC8F.1040702@hp.com> <f4845fc0809160831i6868459en6610a7e8b2204367@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Brian Haley <brian.haley@hp.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org
To: Julius Volz <juliusv@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:47047 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751717AbYIQAOl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2008 20:14:41 -0400
Content-Disposition: inline
In-Reply-To: <f4845fc0809160831i6868459en6610a7e8b2204367@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 16, 2008 at 05:31:39PM +0200, Julius Volz wrote:
> On Tue, Sep 16, 2008 at 5:11 PM, Brian Haley <brian.haley@hp.com> wrote:
> > Change __contant_htons() to htons() in the IPVS code when not in an
> > initializer.
> >
> > -Brian
> >
> > Signed-off-by: Brian Haley <brian.haley@hp.com>
> 
> Thanks. I somehow missed that in the patch series that got in,
> although you mentioned it before, sorry!
> 
> Julius

Thanks, applied to the lvs-next-2.6 branch of lvs-2.6.

-- 
Simon Horman
  VA Linux Systems Japan K.K., Sydney, Australia Satellite Office
  H: www.vergenet.net/~horms/             W: www.valinux.co.jp/en

