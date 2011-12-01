From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [GIT PULL v2] Open vSwitch
Date: Thu, 1 Dec 2011 15:52:37 +0800
Message-ID: <20111201075237.GA12799@gondor.apana.org.au>
References: <20111123075433.GA7928@gondor.apana.org.au> <1322050976.2039.125.camel@mojatatu> <20111128130409.GB16828@gondor.apana.org.au> <0199E0D51A61344794750DC57738F58E7586A74137@GVW1118EXC.americas.hpqcorp.net> <20111128145157.GA17678@gondor.apana.org.au> <CAEP_g=_Mj9az1oSLzUcqT_m05JEJavjcQ1SFeoYtsgk5xvBjBQ@mail.gmail.com> <20111130070219.GB32630@gondor.apana.org.au> <20111201072418.GA18436@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesse Gross <jesse@nicira.com>,
	"Fischer, Anna" <anna.fischer@hp.com>,
	"jhs@mojatatu.com" <jhs@mojatatu.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:42182 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753107Ab1LAHw5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2011 02:52:57 -0500
Content-Disposition: inline
In-Reply-To: <20111201072418.GA18436@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 01, 2011 at 04:24:18PM +0900, Simon Horman wrote:
>
> So while I agree that optimizing the hash is a good idea.  I don't believe
> it is a bottle-neck at this point. Though I could be convinced otherwise if
> long collision chains could be constructed with relatively few flows.
> Something I had not considered until I rad your email just now.

It's not an optimisation issue, but a security one.  If you leave
a hash like this with a constant seed, an attacker would have an
infinite amount of time to find collisions.

Rehashing isn't all that difficult.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
