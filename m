From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] macsec: dynamically allocate space for sglist
Date: Wed, 26 Apr 2017 14:42:41 -0400 (EDT)
Message-ID: <20170426.144241.1756957005773510777.davem@davemloft.net>
References: <20170425163602.GA17973@bistromath.localdomain>
        <20170425170818.32661-1-Jason@zx2c4.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        stable@vger.kernel.org, security@kernel.org, sd@queasysnail.net
To: Jason@zx2c4.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20170425170818.32661-1-Jason@zx2c4.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Date: Tue, 25 Apr 2017 19:08:18 +0200

> We call skb_cow_data, which is good anyway to ensure we can actually
> modify the skb as such (another error from prior). Now that we have the
> number of fragments required, we can safely allocate exactly that amount
> of memory.
> 
> Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
> Cc: Sabrina Dubroca <sd@queasysnail.net>
> Cc: security@kernel.org
> Cc: stable@vger.kernel.org

Applied, thanks.
