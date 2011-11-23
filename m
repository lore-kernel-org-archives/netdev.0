From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [GIT PULL v2] Open vSwitch
Date: Wed, 23 Nov 2011 15:54:34 +0800
Message-ID: <20111123075433.GA7928@gondor.apana.org.au>
References: <20111122.155006.361847516719132107.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jesse@nicira.com, netdev@vger.kernel.org, dev@openvswitch.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:48990 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752576Ab1KWHyo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2011 02:54:44 -0500
Content-Disposition: inline
In-Reply-To: <20111122.155006.361847516719132107.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
> 
> I would like to see some discussion wrt. Jamal's feedback, which is that
> a lot of the side-band functionality added by this code is either 1) already
> doable with packet scheduler actions or 2) should be implemented there.

I mostly agree with Jamal.  As far as the concept of a policy
lookup cache goes (which appears to be at the core of OVS), this
almost fits exactly onto a u32 hash table.  All that would be needed
is to add the tail end of the policies, e.g., with new packet
actions.

However, this is purely based on my conceptual view of OVS, which
may or may not be accurate.  I'll dig into the patches over the
next couple of days to see if they could be easily turned into
packet actions or whether this is difficult for reasons that we
have not yet discovered.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
