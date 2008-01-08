From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 3/4] [XFRM]: Kill some bloat
Date: Tue, 8 Jan 2008 12:57:51 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0801081155270.12911@kivilampi-30.cs.helsinki.fi>
References: <1199540349385-git-send-email-ilpo.jarvinen@helsinki.fi>
 <E1JBJOR-0000jO-00@gondolin.me.apana.org.au> <20080105.231658.168081302.davem@davemloft.net>
 <p73sl19qi6o.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Netdev <netdev@vger.kernel.org>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	paul.moore@hp.com, latten@us.ibm.com
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:52494 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750962AbYAHK5w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 05:57:52 -0500
In-Reply-To: <p73sl19qi6o.fsf@bingen.suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 8 Jan 2008, Andi Kleen wrote:

> David Miller <davem@davemloft.net> writes:
> 
> > Similarly I question just about any inline usage at all in *.c files
> 
> Don't forget the .h files. Especially a lot of stuff in tcp.h should
> be probably in some .c file and not be inline.

I'm not forgetting them... :-)

My intention is to do the same for all headers as well but I'd really like 
to get some actual number of bytes by measuring rather than taking them of 
the hat.

...It just requires some work still to get the uninlining actually do the 
right thing and actually testing it involves orders of magnitude more 
exhaustive recompilation than .o only checking required so after finishing 
the script I either has to setup n distcc master with a number of slaves 
each or wait for some time for the results :-).

However, I suspect that anything in tcp.h won't match to something like 
~5-10k like I've seen in three .c files already + one with debugging that 
has even more than 10k (even if all in tcp.h summed up :-)).

-- 
 i.
