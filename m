From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: Re: [PATCH] net: Fix recvmmsg timeout handling
Date: Tue, 22 Jul 2014 16:27:11 -0300
Message-ID: <20140722192711.GF20303@kernel.org>
References: <20140721192131.GA3212@kernel.org>
 <20140721.204538.1952841990990568877.davem@davemloft.net>
 <53CEB49C.5050304@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, caitlin.bestler@gmail.com,
	chris.friesen@windriver.com, David.Laight@ACULAB.COM,
	eliedebrauwer@gmail.com, nhorman@tuxdriver.com, neleai@seznam.cz,
	paul@paul-moore.com, remi@remlab.net, steve@chygwyn.com,
	netdev@vger.kernel.org
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.19.201]:60324 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932101AbaGVT1Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jul 2014 15:27:16 -0400
Content-Disposition: inline
In-Reply-To: <53CEB49C.5050304@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Tue, Jul 22, 2014 at 08:59:40PM +0200, Michael Kerrisk (man-pages) escreveu:
> On 07/22/2014 05:45 AM, David Miller wrote:
> > From: Arnaldo Carvalho de Melo <acme@kernel.org>
> > Date: Mon, 21 Jul 2014 16:21:31 -0300
> > 
> >> 	Trying to get this merged, finally. I has whas has been
> >> discussed so far and agreed wrt the timeout handling.
> > 
> > This gets lots of rejects against the current 'net' tree.
> > 
> > Please respin and integrate Remi's Acked-by, thanks.
> > 
> 
> +1 -- then this patch could be tested...

It was done on top of the net-next tree, I'm finishing a make
allmodconfig to post it on top of davem/net.

- Arnaldo
