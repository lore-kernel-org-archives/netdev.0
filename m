From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: Re: Getting physical packet counts with LRO enabled with ixgbe?
Date: Fri, 25 Sep 2009 14:56:30 -0700
Message-ID: <1253915790.3809.14.camel@localhost.localdomain>
References: <20090925214505.GA3472@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "greearb@candelatech.com" <greearb@candelatech.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:15646 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752257AbZIYV4X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Sep 2009 17:56:23 -0400
In-Reply-To: <20090925214505.GA3472@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-09-25 at 14:45 -0700, Herbert Xu wrote:
> Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com> wrote:
> >
> >> That's a bummer.  I'm guessing you might get close to right on average with some
> >> trivial math, but if someone is sending you pkts with size of 1000 and
> >> your MTU is 1500, would there be any way to tell that the pkts were originally
> >> 1000 bytes instead of 1500?
> > 
> > Good point.
> 
> Well if you did GRO instead of LRO then none of this would matter :)

ixgbe uses GRO, but we have HW RSC/LRO running on 82599 adapters
underneath GRO.

-PJ

