From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] bridge: make bridge-nf-call-*tables default configurable
Date: Wed, 01 Jul 2009 11:21:44 +0200
Message-ID: <4A4B2AA8.3090406@trash.net>
References: <1246379267.3749.42.camel@blaa> <20090630170027.GA22691@gondor.apana.org.au> <4A4B24DE.10103@trash.net> <20090701090736.GA32306@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Mark McLoughlin <markmc@redhat.com>,
	netdev <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:52931 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751727AbZGAJVs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jul 2009 05:21:48 -0400
In-Reply-To: <20090701090736.GA32306@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Wed, Jul 01, 2009 at 10:57:02AM +0200, Patrick McHardy wrote:
>> People are apparently using this for stateful tracking and even
>> NAT on bridges, so I'm afraid we can't get rid of it completely.
> 
> I think we should print out a nasty message warning the user
> if we detect that conntrack is used by bridge netfilter for the
> first time.  If the user persists then at least they can't sue
> us for not warning them :)

Agreed, at least as long as this is still the default behaviour.
Mark, could you add this to your patch? br_nf_pre_routing_finish()
looks like a good place to print a warning when skb->nfct != NULL.

