From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH][IRDA] Compilation for CONFIG_INET=n case
Date: Thu, 22 Nov 2007 19:18:10 +0800
Message-ID: <20071122111810.GA8781@gondor.apana.org.au>
References: <474456C4.8010309@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Samuel Ortiz <samuel@sortiz.org>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3873 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751505AbXKVLSl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Nov 2007 06:18:41 -0500
Content-Disposition: inline
In-Reply-To: <474456C4.8010309@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 21, 2007 at 07:03:16PM +0300, Pavel Emelyanov wrote:
> Found this occasionally. 
> 
> The CONFIG_INET=n is hardly ever set, but if it is the 
> irlan_eth_send_gratuitous_arp() compilation should produce a 
> warning about unused variable in_dev.
> 
> Too pedantic? :)
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Not too pedantic yet, please keep trying :)

Applied to net-2.6.  Thanks!
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
