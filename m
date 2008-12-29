From: Ingo Molnar <mingo@elte.hu>
Subject: Re: unsafe locks seen with netperf on net-2.6.29 tree
Date: Mon, 29 Dec 2008 12:58:27 +0100
Message-ID: <20081229115827.GA441@elte.hu>
References: <20081225112658.GA7260@gondor.apana.org.au> <1230300535.9487.292.camel@twins> <EA929A9653AAE14F841771FB1DE5A1365F56B6648A@rrsmsx501.amr.corp.intel.com> <1230410308.9487.295.camel@twins> <EA929A9653AAE14F841771FB1DE5A1365F56B664A3@rrsmsx501.amr.corp.intel.com> <1230544927.16718.12.camel@twins> <20081229103154.GA9691@gondor.apana.org.au> <20081229103735.GA9763@gondor.apana.org.au> <20081229112858.GA16385@elte.hu> <20081229114907.GA10170@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	"Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	Eric Dumazet <dada1@cosmosbay.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:60239 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752837AbYL2L6n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Dec 2008 06:58:43 -0500
Content-Disposition: inline
In-Reply-To: <20081229114907.GA10170@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Mon, Dec 29, 2008 at 12:28:58PM +0100, Ingo Molnar wrote:
> >
> > i got the splat further below with Peter's workaround applied.
> 
> This looks like the issue that Peter's original patch (the one that 
> differentiated between instances of percpu counters) fixed. Did you have 
> both of his patches applied?

no, i only applied one of them. Is his second patch a good solution in 
your opinion, and should i thus test both of them? (or will the second one 
iterate some more - in which case i will keep the revert for now)

	Ingo
