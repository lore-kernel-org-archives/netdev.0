From: Stefan Rompf <stefan@loplof.de>
Subject: Re: [NET] linkwatch: Handle jiffies wrap-around
Date: Tue, 9 May 2006 18:51:49 +0200
Message-ID: <200605091851.49775.stefan@loplof.de>
References: <200605071213.56877.stefan@loplof.de> <200605082028.57328.stefan@loplof.de> <20060509112626.GA29361@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nattrymon.rzone.de ([81.169.145.178]:60870 "EHLO
	nattrymon.rzone.de") by vger.kernel.org with ESMTP id S1750723AbWEIQva
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 May 2006 12:51:30 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060509112626.GA29361@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Dienstag 09 Mai 2006 13:26 schrieb Herbert Xu:

> The test used in the linkwatch does not handle wrap-arounds correctly.
> Since the intention of the code is to eliminate bursts of messages we
> can afford to delay things up to a second.

looks good, the code generates only up to 1 second delay for one second every 
49 days, avoiding 64bit operations. David, please prefer this patch over mine.

> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Acked-by: Stefan Rompf <stefan@loplof.de>
