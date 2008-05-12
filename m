From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 0/2] Disable forwarding of LRO skbs
Date: Mon, 12 May 2008 15:48:08 +0100
Message-ID: <20080512144807.GH13470@solarflare.com>
References: <20080430214845.GC14219@solarflare.com> <E1JrWFU-0001ue-00@gondolin.me.apana.org.au> <20080501110225.GG14219@solarflare.com> <1209640128.4191.30.camel@moonstone.uk.level5networks.com> <20080501111247.GA7756@gondor.apana.org.au> <1209640688.4191.35.camel@moonstone.uk.level5networks.com> <20080501113716.GA7955@gondor.apana.org.au> <20080501120850.GH14219@solarflare.com> <20080501121945.GA8389@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kieran Mansley <kmansley@solarflare.com>, davem@davemloft.net,
	shemminger@vyatta.com, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:39358 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751598AbYELOsz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2008 10:48:55 -0400
Content-Disposition: inline
In-Reply-To: <20080501121945.GA8389@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Thu, May 01, 2008 at 01:08:51PM +0100, Ben Hutchings wrote:
> >
> > Depending on the driver, the packets may be received into skbs which are
> > then attached to frag_list, or into page buffers which go in the frags
> > array.  If most packets can be merged by LRO, deferring skb allocation
> > and using the frags array is a performance win.
> 
> But for each packet it's either going to be frag_list or page
> frags, right? So we could still fragment based on frag_list if
> it's present.

Please can you post an implementation of this.  I don't want this bug to
be left unfixed.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
