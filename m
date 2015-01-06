From: Florian Westphal <fw@strlen.de>
Subject: Re: IPsec workshop at netdev01?
Date: Tue, 6 Jan 2015 18:00:26 +0100
Message-ID: <20150106170026.GD11324@breakpoint.cc>
References: <20150106101936.GC31458@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:40681 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755933AbbAFRAc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 12:00:32 -0500
Content-Disposition: inline
In-Reply-To: <20150106101936.GC31458@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Steffen Klassert <steffen.klassert@secunet.com> wrote:
> - We still lack a 32/64 bit compatibiltiy layer for IPsec, this issue
>   comes up from time to time. Some solutions were proposed in the past
>   but all had problems. The current behaviour is broken if someone tries
>   to configure IPsec with 32 bit tools on a 64 bit machine. Can we get
>   this right somehow or is it better to just return an error in this case?

FWIW I think
http://patchwork.ozlabs.org/patch/49465/

came closest to achieving full CONFIG_COMPAT support; since netlink is
no longer async now I'm not sure we'd still need additonal 32-compat syscalls
to make compat work for all cases.

So "its ugly as hell" is probably the only problem that is hard to avoid ;-)
