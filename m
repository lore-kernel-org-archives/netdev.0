From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] mac80211: aead api to reduce redundancy
Date: Mon, 25 Sep 2017 12:56:41 +0800
Message-ID: <20170925045641.GB22947@gondor.apana.org.au>
References: <20170924054015.8958-1-qasdfgtyuiop@gmail.com>
 <1506265531.2909.5.camel@sipsolutions.net>
 <CAMtaSwR4YTgh9N9x8a12R4dEZNuarjwvfOmnO6vnaDffVV-j3w@mail.gmail.com>
 <1506274966.2909.7.camel@sipsolutions.net>
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
In-Reply-To: <1506274966.2909.7.camel@sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Sep 24, 2017 at 07:42:46PM +0200, Johannes Berg wrote:
>
> Unrelated to this, I'm not sure whose tree this should go through -
> probably Herbert's (or DaveM's with his ACK? not sure if there's a
> crypto tree?) or so?

Since you're just rearranging code invoking the crypto API, rather
than touching actual crypto API code, I think you should handle it
as you do with any other wireless patch.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
