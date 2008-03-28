From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6.24 BUG: soft lockup - CPU#X
Date: Fri, 28 Mar 2008 21:53:38 +0800
Message-ID: <20080328135338.GA24374@gondor.apana.org.au>
References: <47EC3182.7080005@sun.com> <20080327.170235.53674739.davem@davemloft.net> <47EC399E.90804@sun.com> <20080327.173418.18777696.davem@davemloft.net> <20080328012234.GA20465@gondor.apana.org.au> <47EC50BA.6080908@sun.com> <20080328103809.GB23039@gondor.apana.org.au> <20080328133845.GA14565@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matheos Worku <Matheos.Worku@Sun.COM>,
	David Miller <davem@davemloft.net>, jesse.brandeburg@intel.com,
	netdev@vger.kernel.org, hadi@cyberus.ca
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:43933 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752307AbYC1Nxt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 09:53:49 -0400
Content-Disposition: inline
In-Reply-To: <20080328133845.GA14565@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 28, 2008 at 02:38:45PM +0100, Jarek Poplawski wrote:
> 
> Considering this, I wonder why using this __LINK_STATE_QDISC_RUNNING
> flag to control enqueuing as well would be a wrong idea? Wouldn't this
> enforce pseudo affinity?

Could you elaborate on how you intend to use it to control the
act of enqueueing?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
