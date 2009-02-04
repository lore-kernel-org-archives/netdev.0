From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: GSO checksum warning debug info
Date: Thu, 5 Feb 2009 07:52:36 +1100
Message-ID: <20090204205236.GA26273@gondor.apana.org.au>
References: <20090204002345.GF5220@sequoia.sous-sol.org> <20090204124011.GA22288@gondor.apana.org.au> <20090204161155.GG5220@sequoia.sous-sol.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Chris Wright <chrisw@sous-sol.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:58538 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753559AbZBDUwj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2009 15:52:39 -0500
Content-Disposition: inline
In-Reply-To: <20090204161155.GG5220@sequoia.sous-sol.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 04, 2009 at 08:11:55AM -0800, Chris Wright wrote:
>
> Windows guest.

That makes a lot more sense :) The Windows driver needs to set
a partial checksum in order to use GSO/LSO.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
