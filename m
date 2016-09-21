From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-next 5/7] rhashtable: abstract out function to get
 hash
Date: Wed, 21 Sep 2016 10:46:13 +0800
Message-ID: <20160921024613.GA27473@gondor.apana.org.au>
References: <1473895376-347096-6-git-send-email-tom@herbertland.com>
 <20160920093659.GA20975@gondor.apana.org.au>
 <20160920175803.GE3291@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Herbert <tom@herbertland.com>, davem@davemloft.net,
        netdev@vger.kernel.org, roopa@cumulusnetworks.com,
        kernel-team@fb.com
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:54583 "EHLO
        helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755492AbcIUCq2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 22:46:28 -0400
Content-Disposition: inline
In-Reply-To: <20160920175803.GE3291@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 20, 2016 at 07:58:03PM +0200, Thomas Graf wrote:
> 
> I understand this particular patch as an effort not to duplicate
> hash function selection such as jhash vs jhash2 based on key_len.

If the rhashtable params stay non-const as is then this is going
to produce some monstrous code which will be worse than using
jhash unconditionally.

If the rhashtable params are made const then you'll already know
whether jhash or jhash2 is used.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
