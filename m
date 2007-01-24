From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: why would EPIPE cause socket port to change?
Date: Wed, 24 Jan 2007 16:58:33 +1100
Message-ID: <20070124055833.GA17989@gondor.apana.org.au>
References: <Pine.LNX.4.64.0701221954250.11520@twinlark.arctic.org> <E1H9ES2-0006uJ-00@gondolin.me.apana.org.au> <20070123122652.484c05b3@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dean gaudet <dean@arctic.org>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1885 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1030223AbXAXGXP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jan 2007 01:23:15 -0500
Content-Disposition: inline
In-Reply-To: <20070123122652.484c05b3@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 23, 2007 at 12:26:52PM -0800, Stephen Hemminger wrote:
> 
> Why does write cause an autobind? One would think that on a
> SOCK_STREAM socket, the write should just fail with ENOTCONN

The autobind is occuring in generic code, i.e., inet_sendmsg().
It will subsequently fail because the socket is not connected.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
