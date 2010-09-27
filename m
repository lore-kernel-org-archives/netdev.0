From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: TCP: orphans broken by RFC 2525 #2.17
Date: Tue, 28 Sep 2010 08:28:57 +0900
Message-ID: <20100927232857.GA23803@gondor.apana.org.au>
References: <20100927192112.GT12373@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:39813 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755652Ab0I0X3E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Sep 2010 19:29:04 -0400
Content-Disposition: inline
In-Reply-To: <20100927192112.GT12373@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Willy Tarreau <w@1wt.eu> wrote:
> 
> Two quick facts :
>  - HTTP allows the client to send whatever it wants whenever it wants
>    and allows the server to close after whatever response it wants.
>    Thus the server cannot predict that the client will talk.

No it does not.  Only buggy HTTP clients do that.  Also, have
you ever observed any buggy HTTP client that sends more than
one CRLF? If not then you only have to deal with the case of
a single extra CRLF.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
