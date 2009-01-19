From: David Miller <davem@davemloft.net>
Subject: Re: ixgbe: Replace LRO with GRO
Date: Sun, 18 Jan 2009 21:49:58 -0800 (PST)
Message-ID: <20090118.214958.43175041.davem@davemloft.net>
References: <20090114084412.GA17393@gondor.apana.org.au>
	<20090115034619.GA28267@gondor.apana.org.au>
	<20090115042249.GA29658@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42575
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752566AbZASFt5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 00:49:57 -0500
In-Reply-To: <20090115042249.GA29658@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 15 Jan 2009 15:22:49 +1100

> ixgbe: Replace LRO with GRO
> 
> This patch makes ixgbe invoke the GRO hooks instead of LRO.  As
> GRO has a compatible external interface to LRO this is a very
> straightforward replacement.
> 
> As GRO uses the napi structure to track the held packets, I've
> modified the code paths involved to pass that along.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied for 2.6.30
