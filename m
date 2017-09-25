From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] mac80211: aead api to reduce redundancy
Date: Mon, 25 Sep 2017 07:22:26 +0200
Message-ID: <1506316946.2909.8.camel@sipsolutions.net>
References: <20170924054015.8958-1-qasdfgtyuiop@gmail.com>
         <1506265531.2909.5.camel@sipsolutions.net>
         <CAMtaSwR4YTgh9N9x8a12R4dEZNuarjwvfOmnO6vnaDffVV-j3w@mail.gmail.com>
         <1506274966.2909.7.camel@sipsolutions.net>
         <20170925045641.GB22947@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Xiang Gao <qasdfgtyuiop@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-crypto@vger.kernel.org,
        linux-kernel <linux-kernel@vger.kernel.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170925045641.GB22947@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2017-09-25 at 12:56 +0800, Herbert Xu wrote:
> On Sun, Sep 24, 2017 at 07:42:46PM +0200, Johannes Berg wrote:
> > 
> > Unrelated to this, I'm not sure whose tree this should go through -
> > probably Herbert's (or DaveM's with his ACK? not sure if there's a
> > crypto tree?) or so?
> 
> Since you're just rearranging code invoking the crypto API, rather
> than touching actual crypto API code, I think you should handle it
> as you do with any other wireless patch.

The code moves to crypto/ though, and I'm not even sure I can vouch for
the Makefile choice there.

johannes
