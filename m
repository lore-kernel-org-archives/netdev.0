From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] act_nat: get the position info from skb->tc_verd
Date: Fri, 30 Jul 2010 10:36:49 +0800
Message-ID: <20100730023649.GA5798@gondor.apana.org.au>
References: <1280428952-14151-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <hadi@cyberus.ca>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:53273 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755663Ab0G3Cg7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jul 2010 22:36:59 -0400
Content-Disposition: inline
In-Reply-To: <1280428952-14151-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 30, 2010 at 02:42:32AM +0800, Changli Gao wrote:
> act_nat uses its flags field to determine where it acts. It isn't reliable,
> and can't prevent users from doing wrong settings, and act_nat should get the
> position info from skb->tc_verd as act_mirred does.
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

Nack, the direction controls whether we NAT saddr or daddr.  It's
perfectly OK for someone to NAT daddr on the way out.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
