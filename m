From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Bugme-new] [Bug 13617] New: GRO:__napi_complete from
	net_rx_action crash
Date: Sat, 27 Jun 2009 11:33:53 +0800
Message-ID: <20090627033353.GA20458@gondor.apana.org.au>
References: <4A4501D7.8050301@qlogic.com> <20090626.102458.96012087.davem@davemloft.net> <20090627014900.GA19639@gondor.apana.org.au> <20090626.192804.199785674.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dhananjay.phadke@qlogic.com, akpm@linux-foundation.org,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org, amit.salecha@qlogic.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:43119 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751288AbZF0DeA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2009 23:34:00 -0400
Content-Disposition: inline
In-Reply-To: <20090626.192804.199785674.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 26, 2009 at 07:28:04PM -0700, David Miller wrote:
>
> I remembered that change where we had to disable GRO in the
> legacy RX path and all the IRQ disabling problems we ran into
> there.  So I went and had a look at that to make sure we won't
> have similar issues here, luckily it seems not.

Yeah the netpoll lock is all we need since netpoll is the only
other thing that can race against this.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
