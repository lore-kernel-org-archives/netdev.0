From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: 2.6.24 BUG: soft lockup - CPU#X
Date: Fri, 28 Mar 2008 15:39:53 +0100
Message-ID: <20080328143953.GA14642@ami.dom.local>
References: <47EC3182.7080005@sun.com> <20080327.170235.53674739.davem@davemloft.net> <47EC399E.90804@sun.com> <20080327.173418.18777696.davem@davemloft.net> <20080328012234.GA20465@gondor.apana.org.au> <47EC50BA.6080908@sun.com> <20080328103809.GB23039@gondor.apana.org.au> <20080328133845.GA14565@ami.dom.local> <20080328135338.GA24374@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matheos Worku <Matheos.Worku@Sun.COM>,
	David Miller <davem@davemloft.net>, jesse.brandeburg@intel.com,
	netdev@vger.kernel.org, hadi@cyberus.ca
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.171]:26287 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755785AbYC1Ocy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 10:32:54 -0400
Received: by ug-out-1314.google.com with SMTP id z38so726956ugc.16
        for <netdev@vger.kernel.org>; Fri, 28 Mar 2008 07:32:52 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080328135338.GA24374@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 28, 2008 at 09:53:38PM +0800, Herbert Xu wrote:
> On Fri, Mar 28, 2008 at 02:38:45PM +0100, Jarek Poplawski wrote:
> > 
> > Considering this, I wonder why using this __LINK_STATE_QDISC_RUNNING
> > flag to control enqueuing as well would be a wrong idea? Wouldn't this
> > enforce pseudo affinity?
> 
> Could you elaborate on how you intend to use it to control the
> act of enqueueing?

Probably some backlog would be necessary, similarly to RX. The main
question is how much cache problem is such enqueuing from other CPUs.

Jarek P.
