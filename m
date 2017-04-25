From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH v2] macsec: dynamically allocate space for sglist
Date: Tue, 25 Apr 2017 22:35:55 +0200
Message-ID: <20170425203555.GA9378@bistromath.localdomain>
References: <20170425163602.GA17973@bistromath.localdomain>
 <20170425170818.32661-1-Jason@zx2c4.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        David Miller <davem@davemloft.net>, stable@vger.kernel.org,
        security@kernel.org
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170425170818.32661-1-Jason@zx2c4.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2017-04-25, 19:08:18 +0200, Jason A. Donenfeld wrote:
> We call skb_cow_data, which is good anyway to ensure we can actually
> modify the skb as such (another error from prior). Now that we have the
> number of fragments required, we can safely allocate exactly that amount
> of memory.
> 
> Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
> Cc: Sabrina Dubroca <sd@queasysnail.net>
> Cc: security@kernel.org
> Cc: stable@vger.kernel.org

Acked-by: Sabrina Dubroca <sd@queasysnail.net>

Fixes: c09440f7dcb3 ("macsec: introduce IEEE 802.1AE driver")
Fixes: CVE-2017-7477

David, this fix is essentially equivalent to my patch "macsec: avoid
heap overflow in skb_to_sgvec on receive".  Feel free to pick my patch
if you prefer (it's smaller), but this looks ok to me.


Thanks,

-- 
Sabrina
