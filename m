From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6.24 BUG: soft lockup - CPU#X
Date: Fri, 28 Mar 2008 22:56:34 +0800
Message-ID: <20080328145634.GA24712@gondor.apana.org.au>
References: <47EC3182.7080005@sun.com> <20080327.170235.53674739.davem@davemloft.net> <47EC399E.90804@sun.com> <20080327.173418.18777696.davem@davemloft.net> <20080328012234.GA20465@gondor.apana.org.au> <47EC50BA.6080908@sun.com> <20080328103809.GB23039@gondor.apana.org.au> <20080328133845.GA14565@ami.dom.local> <20080328135338.GA24374@gondor.apana.org.au> <20080328143953.GA14642@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matheos Worku <Matheos.Worku@Sun.COM>,
	David Miller <davem@davemloft.net>, jesse.brandeburg@intel.com,
	netdev@vger.kernel.org, hadi@cyberus.ca
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:46585 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753778AbYC1O4u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 10:56:50 -0400
Content-Disposition: inline
In-Reply-To: <20080328143953.GA14642@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 28, 2008 at 03:39:53PM +0100, Jarek Poplawski wrote:
> 
> Probably some backlog would be necessary, similarly to RX. The main

Sorry but I still don't understand how this would differ from
what we do now.  As it stands the packet would be queued for
later processing if another CPU is doing a qdisc run.

> question is how much cache problem is such enqueuing from other CPUs.

It's pretty bad actually.  In fact multiple TX queues isn't
going to be useful until we address this bottle-neck.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
