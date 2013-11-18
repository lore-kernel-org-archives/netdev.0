From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v3] net: Do not include padding in TCP GRO checksum
Date: Mon, 18 Nov 2013 08:03:37 +0800
Message-ID: <20131118000337.GA24090@gondor.apana.org.au>
References: <20131115225856.6988.69733.stgit@ahduyck-fpga.jf.intel.com>
 <20131116004738.GA1491@gondor.apana.org.au>
 <20131116015301.GA1999@gondor.apana.org.au>
 <5286F018.8060801@gmail.com>
 <20131116064611.GA12146@gondor.apana.org.au>
 <5287A52A.2060802@gmail.com>
 <20131117031710.GA18254@gondor.apana.org.au>
 <528909E4.1000100@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexander Duyck <alexander.h.duyck@intel.com>, davem@davemloft.net,
	netdev@vger.kernel.org, edumazet@google.com
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:56681 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751750Ab3KRADp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Nov 2013 19:03:45 -0500
Content-Disposition: inline
In-Reply-To: <528909E4.1000100@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 17, 2013 at 10:24:36AM -0800, Alexander Duyck wrote:
>
> It seems like it would be much more likely that a checksum error
> occuring with a padded frame would corrupt the flow identifying data
> then one that isn't padded.

Well it doesn't matter anyway because if a packet has an incorrect
checksum it'll be dropped by the receiving stack anyway so a little
reordering is not going to do any harm.  After all, to be 100%
correct, you'd have to flush every single flow between those IP
addresses which is just silly.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
