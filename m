From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/3] uapi glibc compat: fix musl libc compatibility
Date: Thu, 20 Apr 2017 16:36:30 -0400 (EDT)
Message-ID: <20170420.163630.313375940241598525.davem@davemloft.net>
References: <20170418210036.26039-1-hauke@hauke-m.de>
        <20170420.160739.1263793303398330801.davem@davemloft.net>
        <1492719277.8404.16.camel@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hauke@hauke-m.de, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, jarod@redhat.com, jogo@openwrt.org,
        david.heidelberger@ixit.cz, maillist-linux@barfooze.de,
        mikko.rapeli@iki.fi
To: dwmw2@infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1492719277.8404.16.camel@infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Woodhouse <dwmw2@infradead.org>
Date: Thu, 20 Apr 2017 21:14:37 +0100

> I agree, except I don't think you're going far enough. Those "standard
> names" you mention... some of this stuff actually depends on __GLIBC__,
> and *that* isn't right either.

Yep, that's something that needs correcting.
