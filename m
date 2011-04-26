From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net-2.6 4/4] xfrm: Fix integer underrun on zero sized
 replay windows
Date: Tue, 26 Apr 2011 12:58:40 +0200
Message-ID: <20110426105840.GJ5495@secunet.com>
References: <20110426053923.GF5495@secunet.com>
 <20110426054232.GI5495@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:48534 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754433Ab1DZK6J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Apr 2011 06:58:09 -0400
Content-Disposition: inline
In-Reply-To: <20110426054232.GI5495@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 26, 2011 at 07:42:32AM +0200, Steffen Klassert wrote:
> The check if the replay window is contained within one subspace or
> spans over two subspaces causes an unwanted integer underrun on
> zero sized replay windows when we subtract minus one. We fix this by
> changeing this check to avoid the subtraction.
> 

Don't apply this one, it does not fix the issue completely.
I'll send a better one, sorry.
