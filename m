From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [IPSEC] RFC 4301 PFP Support
Date: Wed, 12 Dec 2007 09:52:54 +0800
Message-ID: <20071212015253.GC20618@gondor.apana.org.au>
References: <20071211213445.GA11887@hestia>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, latten@us.ibm.com, davem@davemloft.net
To: Tyler Hicks <tyhicks@ou.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4739 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752402AbXLLBw7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 20:52:59 -0500
Content-Disposition: inline
In-Reply-To: <20071211213445.GA11887@hestia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 11, 2007 at 01:34:45PM -0800, Tyler Hicks wrote:
>
> Should we just use the larval selectors or should we assume that
> openswan will begin to send valid selectors?  I asked for the openswan
> dev's opinions and they referred me to Herbert Xu.  It seems as though
> the correct solution would be for openswan to pass valid selectors in
> UPDSA messages, even if it is the larval selectors we gave them.

Yes we should patch openswan to generate the correct SA selectors.

With the previous standard SA selectors were redundant due to the
presence of policy selectors.  But with RFC 4301 the KM should
start setting them.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
