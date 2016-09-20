From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [v3 PATCH 1/2] rhashtable: Add rhlist interface
Date: Tue, 20 Sep 2016 09:52:44 +0800
Message-ID: <20160920015244.GA18318@gondor.apana.org.au>
References: <20160919105854.GA12892@gondor.apana.org.au>
 <E1blwIz-0003Mz-HD@gondolin.me.apana.org.au>
 <20160919211621.GA20951@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-wireless@vger.kernel.org, tom@herbertland.com,
        Ben Greear <greearb@candelatech.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:47170 "EHLO
        helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752654AbcITBwy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 21:52:54 -0400
Content-Disposition: inline
In-Reply-To: <20160919211621.GA20951@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 19, 2016 at 11:16:21PM +0200, Thomas Graf wrote:
>
> Nice, I like how this simplifies users! Is this suitable for
> ILA as well?

Does it have duplicate objects and use inelastic_security? If so
then yes it should switch over to rhlist.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
