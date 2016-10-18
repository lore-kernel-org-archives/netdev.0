From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 00/28] Reenable maybe-uninitialized warnings
Date: Mon, 17 Oct 2016 22:08:04 -0700
Message-ID: <20161018050804.GA9902@infradead.org>
References: <20161017220342.1627073-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        linux-kernel@vger.kernel.org, x86@kernel.org,
        linux-media@vger.kernel.org,
        Mauro Carvalho Chehab <mchehab@kernel.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        linux-s390@vger.kernel.org, Ilya Dryomov <idryomov@gmail.com>,
        dri-devel@lists.freedesktop.org, linux-mtd@lists.infradead.org,
        Herbert Xu <herbert@gondor.apana.org.au>,
        linux-crypto@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        ceph-devel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net,
        linux-ext4@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-ext4-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161017220342.1627073-1-arnd@arndb.de>
Sender: linux-ext4-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 18, 2016 at 12:03:28AM +0200, Arnd Bergmann wrote:
> This is a set of patches that I hope to get into v4.9 in some form
> in order to turn on the -Wmaybe-uninitialized warnings again.

Hi Arnd,

I jsut complained to Geert that I was introducing way to many
bugs or pointless warnings for some compilers lately, but gcc didn't
warn me about them.  From a little research the lack of
-Wmaybe-uninitialized seems to be the reason for it, so I'm all
for re-enabling it.
