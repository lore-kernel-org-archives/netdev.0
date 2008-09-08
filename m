From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ipvs: Restrict connection table size via Kconfig
Date: Tue, 9 Sep 2008 09:52:33 +1000
Message-ID: <20080908235232.GH13048@verge.net.au>
References: <alpine.LNX.2.00.0809081332270.18192@titan.stealer.net> <f4845fc0809080713u3da3d7d7g5df8810a19c9306c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sven Wegener <sven.wegener@stealer.net>,
	Julian Anastasov <ja@ssi.bg>, lvs-devel@vger.kernel.org,
	netdev@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>
To: Julius Volz <juliusv@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:50750 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753023AbYIHXwf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2008 19:52:35 -0400
Content-Disposition: inline
In-Reply-To: <f4845fc0809080713u3da3d7d7g5df8810a19c9306c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 08, 2008 at 04:13:54PM +0200, Julius Volz wrote:
> On Mon, Sep 8, 2008 at 1:38 PM, Sven Wegener wrote:
> > Instead of checking the value in include/net/ip_vs.h, we can just
> > restrict the range in our Kconfig file. This will prevent values outside
> > of the range early.
> >
> > Signed-off-by: Sven Wegener <sven.wegener@stealer.net>
> > ---
> >  include/net/ip_vs.h   |   10 +---------
> >  net/ipv4/ipvs/Kconfig |    3 ++-
> >  2 files changed, 3 insertions(+), 10 deletions(-)
> >
> > Don't know if we really should remove the check in ip_vs.h, but to some
> > part we should trust our own code.
> 
> Seems ok!

I agree, this sounds entirely reasonable to me.

> > Based on lvs-next.

Thanks, applied.
