From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: NIC data corruption
Date: Wed, 04 Apr 2007 15:00:07 +1000
Message-ID: <E1HYxbL-00088P-00@gondolin.me.apana.org.au>
References: <20070402180717.GA32435@one.firstfloor.org>
Cc: rick.jones2@hp.com, andi@firstfloor.org, aaronl@vitelus.com,
	jim@jtan.com, netdev@vger.kernel.org
To: andi@firstfloor.org (Andi Kleen)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2577 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S2992579AbXDDFAz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2007 01:00:55 -0400
In-Reply-To: <20070402180717.GA32435@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andi Kleen <andi@firstfloor.org> wrote:
> 
> Just providing a general global "disable hardware checksumming"
> knob for the paranoid would be much easier. I guess that would
> be a good idea.

FWIW you can disable RX checksuming with

	ethtool -K <ifname> rx off

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
