From: Ingo Molnar <mingo@elte.hu>
Subject: Re: include/linux/pcounter.h
Date: Wed, 27 Feb 2008 08:36:50 +0100
Message-ID: <20080227073650.GC4638@elte.hu>
References: <20080216112618.ec450f9b.akpm@linux-foundation.org> <20080216.215401.20463603.davem@davemloft.net> <20080226092454.GA10987@elte.hu> <20080226.133531.69481052.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, dada1@cosmosbay.com,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:49026 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750921AbYB0Hh1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Feb 2008 02:37:27 -0500
Content-Disposition: inline
In-Reply-To: <20080226.133531.69481052.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* David Miller <davem@davemloft.net> wrote:

> > but the main and fundamental question still remains unanswered (more 
> > than 3 weeks after Andrew asked that question): why was this piece 
> > of general infrastructure merged via net.git and not submitted to 
> > lkml ever? The code touching -mm does _not_ count as "review".
> 
> I already stated this was a mistake and it won't happen again in the 
> future.

sorry - that bit of the thread didnt seem to make it to lkml. I just saw 
this incomplete discussion with a denial and with no resolution.

And you did the right thing anyway by thinking in terms of a generic 
piece of infrastructure instead of hiding it away into say 
include/net/pcounter.h (which nobody could have objected against).

I sometimes think that the forced isolation of subsystems (rather 
strongly enforced both by -mm and by linux-next) and their hiding away 
on non-lkml lists will eventually hurt the core kernel because less and 
less people will be willing to go the trouble of doing proper 
cross-subsystem development. That results in duplicated or specialistic 
infrastructure, increased code size and longer term, ultimately less 
performance. (by the time we notice _that_ it will probably be too late 
to do anything about it)

	Ingo
