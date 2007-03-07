From: David Miller <davem@davemloft.net>
Subject: Re: [UDP]: Reread uh pointer after pskb_trim
Date: Tue, 06 Mar 2007 20:27:26 -0800 (PST)
Message-ID: <20070306.202726.48807189.davem@davemloft.net>
References: <20070306010020.GA25265@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51558
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932562AbXCGE13 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 23:27:29 -0500
In-Reply-To: <20070306010020.GA25265@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 6 Mar 2007 12:00:20 +1100

> Hi Dave:
> 
> [UDP]: Reread uh pointer after pskb_trim
> 
> The header may have moved when trimming.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

IPV6 got this case right :-)

Applied, and I'll push this to -stable too.
