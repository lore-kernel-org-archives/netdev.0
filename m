From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: IPsec workshop at netdev01?
Date: Wed, 7 Jan 2015 11:31:37 +0100
Message-ID: <20150107103137.GB13046@secunet.com>
References: <20150106101936.GC31458@secunet.com>
 <20150106170026.GD11324@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, Jamal Hadi Salim <jhs@mojatatu.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:50979 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752334AbbAGKbl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jan 2015 05:31:41 -0500
Content-Disposition: inline
In-Reply-To: <20150106170026.GD11324@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 06, 2015 at 06:00:26PM +0100, Florian Westphal wrote:
> Steffen Klassert <steffen.klassert@secunet.com> wrote:
> > - We still lack a 32/64 bit compatibiltiy layer for IPsec, this issue
> >   comes up from time to time. Some solutions were proposed in the past
> >   but all had problems. The current behaviour is broken if someone tries
> >   to configure IPsec with 32 bit tools on a 64 bit machine. Can we get
> >   this right somehow or is it better to just return an error in this case?
> 
> FWIW I think
> http://patchwork.ozlabs.org/patch/49465/
> 
> came closest to achieving full CONFIG_COMPAT support; since netlink is
> no longer async now I'm not sure we'd still need additonal 32-compat syscalls
> to make compat work for all cases.
> 
> So "its ugly as hell" is probably the only problem that is hard to avoid ;-)

Yeah, and it will be no fun to maintain it...

So the question is still, do we really need/want it or should we
tell that this is not supported. We just can't leave it as it is.
We allow to configure with 32 bit tools, but the result is crap.
