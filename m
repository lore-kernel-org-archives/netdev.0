From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] [UDP]: Restore missing inDatagrams increments
Date: Wed, 05 Dec 2007 01:53:01 -0800 (PST)
Message-ID: <20071205.015301.87202109.davem@davemloft.net>
References: <20071204130109.GA3098@gondor.apana.org.au>
	<47560215.6050104@cn.fujitsu.com>
	<20071205021559.GA27707@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wangchen@cn.fujitsu.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55552
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753403AbXLEJxD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 04:53:03 -0500
In-Reply-To: <20071205021559.GA27707@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 5 Dec 2007 13:15:59 +1100

> On Wed, Dec 05, 2007 at 09:42:45AM +0800, Wang Chen wrote:
> > 
> > I apologize for my miss in previous patch.
> > 
> > Herbert, don't you think the udp6inDatagrams should be counted too
> > in xprtsock?
> 
> Good point.  Here's a better version.
> 
> [UDP]: Restore missing inDatagrams increments
>     
> The previous move of the the UDP inDatagrams counter caused the
> counting of encapsulated packets, SUNRPC data (as opposed to call)
> packets and RXRPC packets to go missing.
>     
> This patch restores all of these.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
