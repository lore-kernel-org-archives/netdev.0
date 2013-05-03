From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Patch net-next v3 2/3] bridge: only expire the mdb entry when
 query is received
Date: Fri, 3 May 2013 17:30:17 +0800
Message-ID: <20130503093017.GA12471@gondor.apana.org.au>
References: <1367305819-14013-1-git-send-email-amwang@redhat.com>
 <1367305819-14013-2-git-send-email-amwang@redhat.com>
 <20130502015938.GA2237@gondor.apana.org.au>
 <1367553022.2415.55.camel@cr0>
 <20130503040102.GA10898@gondor.apana.org.au>
 <1367564926.2415.56.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Adam Baker <linux@baker-net.org.uk>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:53604 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752315Ab3ECJaX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 May 2013 05:30:23 -0400
Content-Disposition: inline
In-Reply-To: <1367564926.2415.56.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 03, 2013 at 03:08:46PM +0800, Cong Wang wrote:
> On Fri, 2013-05-03 at 12:01 +0800, Herbert Xu wrote:
> > 
> > I think I quoted the wrong hunk in the patch, I meant the code
> > that arms the timer should no longer be in the leave_group function
> > unless we just sent a query ourselves (and in that case the expiration
> > should also be adjusted accordingly).
> 
> Is the following patch what you meant?

Right, but also add the corresponding timers in case we send a
group-specific query since that won't loop back to ourselves.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
