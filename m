From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [v3] skbuff: Do not scrub skb mark within the same name space
Date: Thu, 16 Apr 2015 15:59:52 +0800
Message-ID: <20150416075952.GA13496@gondor.apana.org.au>
References: <20150415100107.GA3655@gondor.apana.org.au>
 <552E3B7A.2040701@6wind.com>
 <20150415102229.GA3917@gondor.apana.org.au>
 <20150415135739.GA5534@gondor.apana.org.au>
 <552E86A6.9000101@6wind.com>
 <20150416010326.GA10864@gondor.apana.org.au>
 <alpine.LRH.2.11.1504161700130.23392@namei.org>
 <552F6643.4090206@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Morris <jmorris@namei.org>, netdev@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	linux-security-module@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:46107 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753340AbbDPIAF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 04:00:05 -0400
Content-Disposition: inline
In-Reply-To: <552F6643.4090206@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 16, 2015 at 09:35:31AM +0200, Nicolas Dichtel wrote:
> Herbert, could you send a v4 of your patch with the secmark included?

Actually this should go into a separate patch because it's a
straight revert and also that unlike the mark this should never
be cleared, even when you cross a namespace boundary.

But I will send a patch.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
