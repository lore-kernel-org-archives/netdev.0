From: David Miller <davem@davemloft.net>
Subject: Re: inet: Replace left-over references to inet->cork
Date: Tue, 01 Mar 2011 23:01:11 -0800 (PST)
Message-ID: <20110301.230111.104062530.davem@davemloft.net>
References: <20110301123519.GA7453@gondor.apana.org.au>
	<E1PuOop-0001xh-HK@gondolin.me.apana.org.au>
	<20110302061517.GA17891@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, therbert@google.com, wsommerfeld@google.com,
	daniel.baluta@gmail.com, netdev@vger.kernel.org,
	tgraf@infradead.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49906
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751853Ab1CBHAf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 02:00:35 -0500
In-Reply-To: <20110302061517.GA17891@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 2 Mar 2011 14:15:17 +0800

> On Tue, Mar 01, 2011 at 08:36:47PM +0800, Herbert Xu wrote:
>> inet: Remove explicit write references to sk/inet in ip_append_data
> 
> Just found a couple of spots where inet->cork was still used
> instead of just cork.
> 
> inet: Replace left-over references to inet->cork

Applied, thanks Herbert.
