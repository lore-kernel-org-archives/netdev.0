From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: csum offload and af_packet
Date: Tue, 12 Aug 2008 08:32:44 +0800
Message-ID: <20080812003244.GA18230@gondor.apana.org.au>
References: <E1KSU3v-00037r-00@gondolin.me.apana.org.au> <200808112350.25514.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: anthony@codemonkey.ws, netdev@vger.kernel.org, davem@davemloft.net
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:43033 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753632AbYHLAiN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2008 20:38:13 -0400
Content-Disposition: inline
In-Reply-To: <200808112350.25514.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 11, 2008 at 11:50:25PM +1000, Rusty Russell wrote:
>
> I think this is deeper than that.  This case is actually unusual, in that the 
> packet really does arrive with a partial csum.  But usually, we're exposing 
> an internal detail of our stack at this point.  Seems like we shouldn't if we 
> know the user can't deal with it.  dhcpd just makes this case less academic.

I disagree.  If you're using AF_PACKET you're asking to see the
bare details.  If you want to see the censored version you can
always go through the IP stack.

> We can trivially disable it in the guest or host; that's not the problem.  We 
> can even disable csum offload just for UDP in the host.  But should we 
> really?

It's not about disabling it, it's about enabling it dynamically
once guest user-space is sure that *it* can handle this.

Cheers,`
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
