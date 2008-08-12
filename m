From: David Miller <davem@davemloft.net>
Subject: Re: csum offload and af_packet
Date: Mon, 11 Aug 2008 17:51:54 -0700 (PDT)
Message-ID: <20080811.175154.168708843.davem@davemloft.net>
References: <E1KSU3v-00037r-00@gondolin.me.apana.org.au>
	<200808112350.25514.rusty@rustcorp.com.au>
	<20080812003244.GA18230@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, anthony@codemonkey.ws,
	netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44057
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751283AbYHLAvx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2008 20:51:53 -0400
In-Reply-To: <20080812003244.GA18230@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 12 Aug 2008 08:32:44 +0800

> On Mon, Aug 11, 2008 at 11:50:25PM +1000, Rusty Russell wrote:
> >
> > I think this is deeper than that.  This case is actually unusual, in that the 
> > packet really does arrive with a partial csum.  But usually, we're exposing 
> > an internal detail of our stack at this point.  Seems like we shouldn't if we 
> > know the user can't deal with it.  dhcpd just makes this case less academic.
> 
> I disagree.  If you're using AF_PACKET you're asking to see the
> bare details.  If you want to see the censored version you can
> always go through the IP stack.

Unfortunately the censored version doesn't allow you to get at the
link level headers, which is what at least some of these applications
want.
