From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Integration of Open vSwitch
Date: Wed, 30 Nov 2011 23:47:15 +0800
Message-ID: <20111130154715.GB4487@gondor.apana.org.au>
References: <CAEP_g=-g5g0Z30gYBDAZ8s7ACCZSy5MLJpPDxQmmc8m1wbk3tg@mail.gmail.com> <20111130070011.GA32630@gondor.apana.org.au> <1322658891.2243.15.camel@mojatatu> <20111130134028.GA3226@gondor.apana.org.au> <1322661715.2243.33.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesse Gross <jesse@nicira.com>, netdev <netdev@vger.kernel.org>,
	dev@openvswitch.org, David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Chris Wright <chrisw@redhat.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:44636 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752433Ab1K3PrZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 10:47:25 -0500
Content-Disposition: inline
In-Reply-To: <1322661715.2243.33.camel@mojatatu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 30, 2011 at 09:01:55AM -0500, jamal wrote:
>
> Ah yes, them locks. Unless you start doing per-cpu tables
> with lazy synchronization i am not sure how to avoid that.
> Note: last time (time flies) i compared against iptables, the tc flow
> setup/teardown was pretty consistent regardless of table size
> relatively speaking.

iptables sets a pretty low bar :)

For a flow cache I think going per-cpu or at least per-node will
be unavoidable.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
