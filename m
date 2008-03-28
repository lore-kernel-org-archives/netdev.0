From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: 2.6.24 BUG: soft lockup - CPU#X
Date: Fri, 28 Mar 2008 16:47:36 +0100
Message-ID: <20080328154736.GC14642@ami.dom.local>
References: <47EC399E.90804@sun.com> <20080327.173418.18777696.davem@davemloft.net> <20080328012234.GA20465@gondor.apana.org.au> <47EC50BA.6080908@sun.com> <20080328103809.GB23039@gondor.apana.org.au> <20080328133845.GA14565@ami.dom.local> <20080328135338.GA24374@gondor.apana.org.au> <20080328143953.GA14642@ami.dom.local> <20080328145634.GA24712@gondor.apana.org.au> <20080328152953.GB14642@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matheos Worku <Matheos.Worku@Sun.COM>,
	David Miller <davem@davemloft.net>, jesse.brandeburg@intel.com,
	netdev@vger.kernel.org, hadi@cyberus.ca
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hu-out-0506.google.com ([72.14.214.229]:14140 "EHLO
	hu-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751977AbYC1PkG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 11:40:06 -0400
Received: by hu-out-0506.google.com with SMTP id 19so2965794hue.21
        for <netdev@vger.kernel.org>; Fri, 28 Mar 2008 08:40:05 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080328152953.GB14642@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 28, 2008 at 04:29:53PM +0100, Jarek Poplawski wrote:
...
> But during this, now limited, time of qdisc_run() there is a contention
> for queue_lock and probably some additional cache updating because of
> this other enqueuing, which could be delayed especially if queue length
> is above some level.

...Hm... this would need some special treatment for RT traffic yet...

Jarek P.
