From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: bridge: Fix fatal typo in setup of multicast_querier_expired
Date: Mon, 30 Apr 2012 09:04:28 -0700
Message-ID: <20120430090428.2e7d96f4@nehalam.linuxnetplumber.net>
References: <20120430102256.GA32587@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:41571 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755126Ab2D3QEc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Apr 2012 12:04:32 -0400
In-Reply-To: <20120430102256.GA32587@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 30 Apr 2012 20:22:56 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Unfortunately it seems that I didn't properly test the case of
> an expired external querier in the recent multicast bridge series.
> 
> The setup of the timer in that case is completely broken and leads
> to a NULL-pointer dereference.  This patch fixes it.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Acked-by: Stephen Hemminger <shemminger@vyatta.com>
