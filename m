From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] [NET] [0/2] pskb_expand_head() bugfix
Date: Thu, 27 Mar 2008 08:13:49 +0800
Message-ID: <20080327001349.GA8569@gondor.apana.org.au>
References: <47E946C8.6020006@redhat.com> <20080325235536.GB30298@gondor.apana.org.au> <47EAB667.6010308@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Hideo AOKI <haoki@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:59914 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753399AbYC0ANv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2008 20:13:51 -0400
Content-Disposition: inline
In-Reply-To: <47EAB667.6010308@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 26, 2008 at 04:47:35PM -0400, Hideo AOKI wrote:
>
> Or, should I simply add truesize calculation after
> pskb_expand_head() calls which change truesize?

Can you do an audit first and tell us how many sites are currently
buggy?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
