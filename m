From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [GIT PULL v2] Open vSwitch
Date: Wed, 30 Nov 2011 15:06:47 +0800
Message-ID: <20111130070647.GC32630@gondor.apana.org.au>
References: <20111123075433.GA7928@gondor.apana.org.au> <1322050976.2039.125.camel@mojatatu> <20111128130409.GB16828@gondor.apana.org.au> <CAEP_g=-+F8bpkb8Qe1bPk65PQVNxz+VO7NoUrBCw6=GDUFbOFg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jhs@mojatatu.com, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, dev@openvswitch.org
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:44509 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751457Ab1K3HGy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 02:06:54 -0500
Content-Disposition: inline
In-Reply-To: <CAEP_g=-+F8bpkb8Qe1bPk65PQVNxz+VO7NoUrBCw6=GDUFbOFg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 29, 2011 at 10:18:02PM -0800, Jesse Gross wrote:
>
> The main part that worries me about moving to a different approach is
> the impedance mismatch that occurs from the fact that Open vSwitch is
> modeling a switch and tc is not.  As Jamal alluded to above, it's
> actually the bridge code which is more conceptually similar.  In my
> experience, combining two disparate models makes things harder over
> the long run, not easier.  It also tends to show up more in some of
> the edges like userspace/kernel compatibility.

>From what I've seen in the kernel part of OVS, the most striking
thing is that it has almost nothing to do with a switch/bridge :)

In fact, if you got rid of those data path objects, and just did
things based off the vports, I reckon it would still work and do
pretty much the same thing.

For example, if you wanted you could actually use the same mechanism
to do routing.

However, I don't think we need to distract ourselves by these
grand visions right now, as the OVS patch AFAICS is sufficiently
self-contained that it does not constrain us from future changes
like this.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
