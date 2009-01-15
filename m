From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Sending complete IPv6 packets without bypassing netfilter/IPsec
Date: Fri, 16 Jan 2009 10:54:16 +1100
Message-ID: <20090115235416.GA8862@gondor.apana.org.au>
References: <8CB452A85703FEF-9E4-FEB@FWM-M04.sysops.aol.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jpo234@netscape.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:49752 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753049AbZAOXyV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 18:54:21 -0500
Content-Disposition: inline
In-Reply-To: <8CB452A85703FEF-9E4-FEB@FWM-M04.sysops.aol.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

jpo234@netscape.net wrote:
> the IPv4 socket interface had the nifty IP_HDRINCL option. It seems 
> that an IPv6 version of this option is not available. The proposed 
> solution for this seems to be to use libpcap to inject the packet. 
> Unfortunately this completely bypasses both, netfilter and IPsec. So, 
> am I lost or is there a way to do what I want/need?

	socket(AF_INET6, SOCK_RAW, IPPROTO_RAW)

should have the same effect as IP_HDRINCL.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
