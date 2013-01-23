From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: pull request (net-next): ipsec-next 2013-01-23
Date: Thu, 24 Jan 2013 08:23:23 +1100
Message-ID: <20130123212323.GA24698@gondor.apana.org.au>
References: <1358929144-17806-1-git-send-email-steffen.klassert@secunet.com>
 <20130123.140058.1653306473705960117.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sting.hengli.com.au ([178.18.18.71]:53759 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751345Ab3AWVXa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 16:23:30 -0500
Content-Disposition: inline
In-Reply-To: <20130123.140058.1653306473705960117.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 23, 2013 at 02:00:58PM -0500, David Miller wrote:
> From: Steffen Klassert <steffen.klassert@secunet.com>
> Date: Wed, 23 Jan 2013 09:18:56 +0100
> 
> > 1) Add a statistic counter for invalid output states and
> >    remove a superfluous state valid check, from Li RongQing.
> > 
> > 2) Probe for asynchronous block ciphers instead of synchronous block
> >    ciphers to make the asynchronous variants available even if no
> >    synchronous block ciphers are found, from Jussi Kivilinna.
> > 
> > 3) Make rfc3686 asynchronous block cipher and make use of
> >    the new asynchronous variant, from Jussi Kivilinna.
> > 
> > 4) Replace some rwlocks by rcu, from Cong Wang.
> > 
> > 5) Remove some unused defines.
> > 
> > Please pull or let me know if there are problems.
> 
> Pulled, thanks Steffen.
> 
> I hope Herbert is ok with the small crypto bits going in this way,
> since they really are IPSEC specific.

No problem at all :)
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
