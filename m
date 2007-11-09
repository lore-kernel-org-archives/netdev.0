From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/1]: Using ICMP type and code in xfrm selector
Date: Fri, 9 Nov 2007 19:29:13 +0800
Message-ID: <20071109112913.GB27984@gondor.apana.org.au>
References: <200711022317.lA2NHeX2018386@faith.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, tgraf@redhat.com
To: Joy Latten <latten@austin.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4084 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751883AbXKIL3o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2007 06:29:44 -0500
Content-Disposition: inline
In-Reply-To: <200711022317.lA2NHeX2018386@faith.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 02, 2007 at 06:17:40PM -0500, Joy Latten wrote:
>
> While fixing this I wondered why we put icmp message
> type in sport and code in dport?

Where we put the info in the kernel is not specified by the
RFC.  It has to document where you put it in IKE because IKE
is used by two systems which must agree on one format.

Your patch looks OK to me but in general we want to encourage
applications to use the xfrm_user interface as pf_key is not
portable anyway because of the lack of a standard specification
that covers the SPD.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
