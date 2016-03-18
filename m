From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] xfrm: don't segment UFO packets
Date: Fri, 18 Mar 2016 10:36:53 +0800
Message-ID: <20160318023653.GA17000@gondor.apana.org.au>
References: <20160129234424.GC7907@midget.suse.cz>
 <20160130042102.GA22809@gondor.apana.org.au>
 <20160316160026.GB19258@midget.suse.cz>
 <20160317050359.GA3840@gondor.apana.org.au>
 <20160317094115.GA11706@midget.suse.cz>
 <20160317102459.GG3347@gauss.secunet.com>
 <20160317170855.GA21145@midget.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Jiri Bohac <jbohac@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:46732 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751241AbcCRChF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2016 22:37:05 -0400
Content-Disposition: inline
In-Reply-To: <20160317170855.GA21145@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 17, 2016 at 06:08:55PM +0100, Jiri Bohac wrote:
> On Thu, Mar 17, 2016 at 11:24:59AM +0100, Steffen Klassert wrote:
> > In IPv6 this check is missing, so this could be the
> > problem if this is IPv6.
> 
> indeed, this patch also fixes my problem:

Hmm, is this what you really want? If I understood you correctly,
you want the fragmentation to occur after IPsec.  So while this
might generate the same output, it is still going to prefragment
the data, only to merge them back for IPsec and then refragment
again.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
