From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PKT_SCHED]: Add stateless NAT
Date: Fri, 28 Sep 2007 12:19:19 +0400
Message-ID: <20070928081918.GB2304@2ka.mipt.ru>
References: <20070927132037.GA17056@gondor.apana.org.au> <20070927132941.GB25353@2ka.mipt.ru> <46FBB296.8020901@trash.net> <20070927.125239.129764503.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, hadi@cyberus.ca
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:51433 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752413AbXI1IUQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Sep 2007 04:20:16 -0400
Content-Disposition: inline
In-Reply-To: <20070927.125239.129764503.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 27, 2007 at 12:52:39PM -0700, David Miller (davem@davemloft.net) wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Thu, 27 Sep 2007 15:39:34 +0200
> 
> > Evgeniy Polyakov wrote:
> > > On Thu, Sep 27, 2007 at 09:20:37PM +0800, Herbert Xu (herbert@gondor.apana.org.au) wrote:
> > > 
> > >>How about putting it in net/core/utils.c?
> > > 
> > > 
> > > I knew, that was a bad idea to try to fix netfilter dependency :)
> > > 
> > > diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
> > 
> > 
> > This looks good to me.
> 
> I still think the nf_*() prefixes should all go and the extern
> prototypes should go into an independant header file.
> 
> These are not netfilter routines, they are "INET" helpers.
> 
> And we should make similar treatment for all of the ipv6
> packet parser helper functions that ipv6 netfilter needs.

Should netfilter still have own nf_ prefixed functions which will just
call the same ones without prefix from inet header?

-- 
	Evgeniy Polyakov
