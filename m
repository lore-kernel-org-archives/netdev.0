From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: network traffic stop with 2.6.29 after ftp put
Date: Wed, 25 Mar 2009 20:09:32 +0800
Message-ID: <20090325120932.GB6351@gondor.apana.org.au>
References: <BAY103-DAV683AFCEC466B8F2E6D8EBB2930@phx.gbl> <BAY103-DAV100CC8DA92566937097718B2930@phx.gbl> <49C8C26B.7070802@cosmosbay.com> <BAY103-DAV11986CBE87674225EDC31EB2930@phx.gbl> <49C8E7FF.7020906@cosmosbay.com> <BAY103-DAV1251BBA7FBA4243359906AB2930@phx.gbl> <BAY103-DAV114D2F6EE08154E75BB064B2900@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <dada1@cosmosbay.com>, netdev@vger.kernel.org
To: Marco Berizzi <pupilla@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:36617 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759359AbZCYMJi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 08:09:38 -0400
Content-Disposition: inline
In-Reply-To: <BAY103-DAV114D2F6EE08154E75BB064B2900@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 25, 2009 at 09:10:29AM +0100, Marco Berizzi wrote:
>
> no, it doesn't fix the problem.
> This morning I got the same problem
> (I was reading the kernel mailing list
> on lkml.indiana.edu with firefox)

Please try the full GRO revert for netif_rx that I just posted.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
