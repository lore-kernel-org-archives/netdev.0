From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [GIT PULL v2] Open vSwitch
Date: Wed, 30 Nov 2011 15:02:19 +0800
Message-ID: <20111130070219.GB32630@gondor.apana.org.au>
References: <20111123075433.GA7928@gondor.apana.org.au> <1322050976.2039.125.camel@mojatatu> <20111128130409.GB16828@gondor.apana.org.au> <0199E0D51A61344794750DC57738F58E7586A74137@GVW1118EXC.americas.hpqcorp.net> <20111128145157.GA17678@gondor.apana.org.au> <CAEP_g=_Mj9az1oSLzUcqT_m05JEJavjcQ1SFeoYtsgk5xvBjBQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Fischer, Anna" <anna.fischer@hp.com>,
	"jhs@mojatatu.com" <jhs@mojatatu.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:40010 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753406Ab1K3HCd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 02:02:33 -0500
Content-Disposition: inline
In-Reply-To: <CAEP_g=_Mj9az1oSLzUcqT_m05JEJavjcQ1SFeoYtsgk5xvBjBQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 29, 2011 at 10:21:32PM -0800, Jesse Gross wrote:
>
> It's userspace which is managing the entries in the kernel hash table
> and it has some intelligence about aging out entries (and specifically
> about doing it more aggressively as the number of entries increases),
> so it's not really unbounded.  In practice, userspace actually keeps
> the number of entries much smaller than the maximum size of the table.

Right, I thought you would have something like this.

But I think you still need to rehash the table periodically, as
otherwise even with a limited number of entries and attacker could
construct long chains in a hash bucket, given enough time.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
