From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v3] net: Do not include padding in TCP GRO checksum
Date: Sun, 17 Nov 2013 11:17:11 +0800
Message-ID: <20131117031710.GA18254@gondor.apana.org.au>
References: <20131115225856.6988.69733.stgit@ahduyck-fpga.jf.intel.com>
 <20131116004738.GA1491@gondor.apana.org.au>
 <20131116015301.GA1999@gondor.apana.org.au>
 <5286F018.8060801@gmail.com>
 <20131116064611.GA12146@gondor.apana.org.au>
 <5287A52A.2060802@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexander Duyck <alexander.h.duyck@intel.com>, davem@davemloft.net,
	netdev@vger.kernel.org, edumazet@google.com
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:53990 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752892Ab3KQDRW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Nov 2013 22:17:22 -0500
Content-Disposition: inline
In-Reply-To: <5287A52A.2060802@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 16, 2013 at 09:02:34AM -0800, Alexander Duyck wrote:
>
> That being the case though, why don't we set the flush flag on detecting
> a bad checksum and hand it off to tcp_gro_receive instead of returning
> NULL?  It seems like it would be in our interest to flush the flow and
> then report the bad checksum instead of keeping the flow and handing off
> the bad checksum to the stack.

Because if the TCP checksum is wrong then it may belong to a
different flow.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
