From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] af_unix: limit unix_tot_inflight
Date: Wed, 24 Nov 2010 17:25:48 +0100
Message-ID: <20101124162548.GA7395@basil.fritz.box>
References: <AANLkTi=Q967xpX0KLMwX-=_4_1AKO5wjHEuJ1TrNjCj9@mail.gmail.com>
 <1290553918.2866.80.camel@edumazet-laptop>
 <1290590335.3464.24.camel@edumazet-laptop>
 <877hg2g4re.fsf@basil.nowhere.org>
 <1290611906.3464.66.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	Vegard Nossum <vegard.nossum@gmail.com>,
	David Miller <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Eugene Teo <eugene@redhat.com>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:41890 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755473Ab0KXQZw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Nov 2010 11:25:52 -0500
Content-Disposition: inline
In-Reply-To: <1290611906.3464.66.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I knew somebody would suggest this ;)
> 
> Hmm, why bother ?
> 
> Do you think 16000 is too big ? Too small ?

I just don't like static limits. Traditionally even the ones
that seemed reasonable at some point were hit by someone
years later.

The latency issue you mention is a valid concern. I guess
an incremental GC would be overkill here ...

-Andi
