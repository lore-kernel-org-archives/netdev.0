From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 0/9 Rev3] Implement batching skb API and support in IPoIB
Date: Sat, 25 Aug 2007 07:11:00 +0800
Message-ID: <20070824231100.GA30660@gondor.apana.org.au>
References: <46CE0BA1.60206@hp.com> <20070823231820.2ae52cc0.billfink@mindspring.com> <1187957657.4255.35.camel@localhost> <20070824.142503.30177455.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, billfink@mindspring.com, rick.jones2@hp.com,
	krkumar2@in.ibm.com, gaagaan@gmail.com,
	general@lists.openfabrics.org, jagana@us.ibm.com, jeff@garzik.org,
	johnpol@2ka.mipt.ru, kaber@trash.net, mcarlson@broadcom.com,
	mchan@broadcom.com, netdev@vger.kernel.org,
	peter.p.waskiewicz.jr@intel.com, rdreier@cisco.com,
	Robert.Olsson@data.slu.se, shemminger@linux-foundation.org,
	sri@us.ibm.com, tgraf@suug.ch, xma@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4880 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757790AbXHXXNe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2007 19:13:34 -0400
Content-Disposition: inline
In-Reply-To: <20070824.142503.30177455.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 24, 2007 at 02:25:03PM -0700, David Miller wrote:
>
> My hunch is that even if in the non-TSO case the TX packets were all
> back to back in the cards TX ring, TSO still spits them out faster on
> the wire.

If this is the case then we should see an improvement by
disabling TSO and enabling GSO.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
