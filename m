From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] mac80211: aead api to reduce redundancy
Date: Mon, 25 Sep 2017 14:14:30 +0800
Message-ID: <20170925061430.GA23808@gondor.apana.org.au>
References: <20170924054015.8958-1-qasdfgtyuiop@gmail.com>
 <1506265531.2909.5.camel@sipsolutions.net>
 <CAMtaSwR4YTgh9N9x8a12R4dEZNuarjwvfOmnO6vnaDffVV-j3w@mail.gmail.com>
 <1506274966.2909.7.camel@sipsolutions.net>
 <20170925045641.GB22947@gondor.apana.org.au>
 <1506316946.2909.8.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Xiang Gao <qasdfgtyuiop@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-crypto@vger.kernel.org,
        linux-kernel <linux-kernel@vger.kernel.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1506316946.2909.8.camel@sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 25, 2017 at 07:22:26AM +0200, Johannes Berg wrote:
> 
> The code moves to crypto/ though, and I'm not even sure I can vouch for
> the Makefile choice there.

Thanks, I missed that.  I don't think this belongs in crypto.
This proposed helper is only useful for wireless so it should
stay there.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
