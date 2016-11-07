From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: rhashtable: how to use insecure_elasticity of rhashtable_params
Date: Mon, 7 Nov 2016 15:55:45 +0800
Message-ID: <20161107075545.GB26538@gondor.apana.org.au>
References: <CADvbK_cPQVT-icKn_2WpKqTyWgVEJikSAbg6=xB3+dt=zcdk0Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, davem <davem@davemloft.net>,
        Phil Sutter <phil@nwl.cc>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:37313 "EHLO
        helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750977AbcKGHz5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2016 02:55:57 -0500
Content-Disposition: inline
In-Reply-To: <CADvbK_cPQVT-icKn_2WpKqTyWgVEJikSAbg6=xB3+dt=zcdk0Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 06, 2016 at 09:15:07PM +0800, Xin Long wrote:
> Now when I don't set  insecure_elasticity, ht->elasticity would be
> set 16, it would be checked in  the loop of __rhashtable_insert_fast
> and rhashtable_lookup_one.

This is now obsolete.  Please use the new rhlist interface.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
