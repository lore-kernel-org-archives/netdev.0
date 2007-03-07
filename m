From: David Miller <davem@davemloft.net>
Subject: Re: [UDP6]: Restore sk_filter optimisation
Date: Tue, 06 Mar 2007 20:30:24 -0800 (PST)
Message-ID: <20070306.203024.106265064.davem@davemloft.net>
References: <20070306012010.GA25763@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58321
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932690AbXCGEa1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 23:30:27 -0500
In-Reply-To: <20070306012010.GA25763@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 6 Mar 2007 12:20:10 +1100

> Hi Dave:
> 
> [UDP6]: Restore sk_filter optimisation
> 
> This reverts the changeset
> 
>     [IPV6]: UDPv6 checksum.
> 
>     We always need to check UDPv6 checksum because it is mandatory.
> 
> The sk_filter optimisation has nothing to do whether we verify the
> checksum.  It simply postpones it to the point when the user calls
> recv or poll.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks.
