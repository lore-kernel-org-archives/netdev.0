From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [mac80211] BUG_ON with current -git (4.8.0-11417-g24532f7)
Date: Wed, 12 Oct 2016 23:12:45 +0900
Message-ID: <20161012141245.GA436@swordfish>
References: <20161010150358.GA514@swordfish>
 <20161010153050.GA836@swordfish>
 <1476263106.5271.23.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
        Andy Lutomirski <luto@kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>,
        linux-next@vger.kernel.org,
        Stephen Rothwell <sfr@canb.auug.org.au>,
        Herbert Xu <herbert@gondor.apana.org.au>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1476263106.5271.23.camel@sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On (10/12/16 11:05), Johannes Berg wrote:
> Sorry - I meant to look into this yesterday but forgot.
> 
> > Andy, can this be related to CONFIG_VMAP_STACK?
> 
> I think it is.

yeah, the system works fine with !CONFIG_VMAP_STACK.

> > > current -git kills my system.
> 
> Can you elaborate on how exactly it kills your system?

the last time I saw it it was a NULL deref at ieee80211_aes_ccm_decrypt.

	-ss
