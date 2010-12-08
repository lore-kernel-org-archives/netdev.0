From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: IPsecv6  tunnel mode fragmentation
Date: Wed, 8 Dec 2010 15:11:09 +0800
Message-ID: <20101208071109.GA14537@gondor.apana.org.au>
References: <1291587520.11224.38.camel@faith.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, samudrala@us.ibm.com, rashmin@us.ibm.com
To: latten@austin.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:42091 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753273Ab0LHHLO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 02:11:14 -0500
Content-Disposition: inline
In-Reply-To: <1291587520.11224.38.camel@faith.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joy Latten <latten@austin.ibm.com> wrote:
> 
> We have come across an ipsec problem that I think was
> noted a while back in the following link.
> http://www.mail-archive.com/netdev@vger.kernel.org/msg61659.html

Looks like a configuration issue to me.  One end is using the
same IP address (*::1234) both within and outside the tunnel.
Thus when the ICMP error message is sent it ends up outside the
tunnel causing it to be discarded by the other side.

So if you're using tunnel mode you really should use distinct
IP addresses.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
