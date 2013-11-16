From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v3] net: Do not include padding in TCP GRO checksum
Date: Sat, 16 Nov 2013 09:43:50 +0800
Message-ID: <20131116014350.GA1895@gondor.apana.org.au>
References: <20131115225856.6988.69733.stgit@ahduyck-fpga.jf.intel.com>
 <20131116004738.GA1491@gondor.apana.org.au>
 <20131115.203427.1522242353491609372.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alexander.h.duyck@intel.com, netdev@vger.kernel.org,
	edumazet@google.com, herbert@gondor.apana.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:40656 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751481Ab3KPBn5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Nov 2013 20:43:57 -0500
Content-Disposition: inline
In-Reply-To: <20131115.203427.1522242353491609372.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 15, 2013 at 08:34:27PM -0500, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Sat, 16 Nov 2013 08:47:38 +0800
> 
> > Also, if the padding occurs on every single packet or a fairly
> > large amount of packets then you should consider improving
> > pskb_trim_rcsum to keep the CHECKSUM_COMPLETE value.
> 
> It should be as easy as this?  (this is actually just a 3 line change,
> it looks like more because I'm moving pskb_trim_rcsum() later in the
> file to where skb_checksum() is in scope).

Looks good to me.  Thanks!
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
