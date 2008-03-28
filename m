From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: 2.6.24 BUG: soft lockup - CPU#X
Date: Fri, 28 Mar 2008 16:29:53 +0100
Message-ID: <20080328152953.GB14642@ami.dom.local>
References: <20080327.170235.53674739.davem@davemloft.net> <47EC399E.90804@sun.com> <20080327.173418.18777696.davem@davemloft.net> <20080328012234.GA20465@gondor.apana.org.au> <47EC50BA.6080908@sun.com> <20080328103809.GB23039@gondor.apana.org.au> <20080328133845.GA14565@ami.dom.local> <20080328135338.GA24374@gondor.apana.org.au> <20080328143953.GA14642@ami.dom.local> <20080328145634.GA24712@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matheos Worku <Matheos.Worku@Sun.COM>,
	David Miller <davem@davemloft.net>, jesse.brandeburg@intel.com,
	netdev@vger.kernel.org, hadi@cyberus.ca
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qb-out-0506.google.com ([72.14.204.232]:24381 "EHLO
	qb-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750995AbYC1PWk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 11:22:40 -0400
Received: by qb-out-0506.google.com with SMTP id e11so5739580qbe.15
        for <netdev@vger.kernel.org>; Fri, 28 Mar 2008 08:22:39 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080328145634.GA24712@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 28, 2008 at 10:56:34PM +0800, Herbert Xu wrote:
> On Fri, Mar 28, 2008 at 03:39:53PM +0100, Jarek Poplawski wrote:
> > 
> > Probably some backlog would be necessary, similarly to RX. The main
> 
> Sorry but I still don't understand how this would differ from
> what we do now.  As it stands the packet would be queued for
> later processing if another CPU is doing a qdisc run.

But during this, now limited, time of qdisc_run() there is a contention
for queue_lock and probably some additional cache updating because of
this other enqueuing, which could be delayed especially if queue length
is above some level.

Cheers,
Jarek P.
