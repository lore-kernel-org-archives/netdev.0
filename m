From: Sebastian Siewior <netdev@ml.breakpoint.cc>
Subject: Re: authenc compile warnings in current net-2.6.24
Date: Wed, 10 Oct 2007 21:53:37 +0200
Message-ID: <20071010195337.GA21597@Chamillionaire.breakpoint.cc>
References: <470D11B1.2040207@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:42739 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755650AbXJJTxj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 15:53:39 -0400
Content-Disposition: inline
In-Reply-To: <470D11B1.2040207@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Oliver Hartkopp | 2007-10-10 19:53:53 [+0200]:

> CC [M] crypto/authenc.o
> crypto/authenc.c: In function ?crypto_authenc_hash?:
> crypto/authenc.c:88: warning: ?cryptlen? may be used uninitialized in this 
> function
> crypto/authenc.c:87: warning: ?dst? may be used uninitialized in this 
> function
> crypto/authenc.c: In function ?crypto_authenc_decrypt?:
> crypto/authenc.c:163: warning: ?cryptlen? may be used uninitialized in this 
> function
> crypto/authenc.c:163: note: ?cryptlen? was declared here
> crypto/authenc.c:162: warning: ?src? may be used uninitialized in this 
> function
> crypto/authenc.c:162: note: ?src? was declared here
>
> do you already know these warnings?

Those warnings are looking like a compiler bug to me.

> Oliver

Sebastian
