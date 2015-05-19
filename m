From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] mac802154: select CRYPTO when needed
Date: Tue, 19 May 2015 19:39:01 +0200
Message-ID: <611EB56D-2A2D-4307-969F-6E7BEAEB597C@holtmann.org>
References: <4189396.LhxDXkIPfr@wuerfel>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2098\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Alexander Aring <alex.aring@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wpan@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-arm-kernel@lists.infradead.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4189396.LhxDXkIPfr@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Arnd,

> The mac802154 subsystem uses functions from the crypto layer and correctly
> selects the individual crypto algorithms, but fails to build when the
> crypto layer is disabled altogether:
> 
> crypto/built-in.o: In function `crypto_ctr_free':
> :(.text+0x80): undefined reference to `crypto_drop_spawn'
> crypto/built-in.o: In function `crypto_rfc3686_free':
> :(.text+0xac): undefined reference to `crypto_drop_spawn'
> crypto/built-in.o: In function `crypto_ctr_crypt':
> :(.text+0x2f0): undefined reference to `blkcipher_walk_virt_block'
> :(.text+0x2f8): undefined reference to `crypto_inc'
> 
> To solve that, this patch also selects the core crypto code,
> like all other users of that code do.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

patch has been applied to bluetooth-next tree.

Regards

Marcel
