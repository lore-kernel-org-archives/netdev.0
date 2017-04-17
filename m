From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH resend 3/4] uapi glibc compat: Do not check for
 __USE_MISC
Date: Mon, 17 Apr 2017 12:55:42 -0400 (EDT)
Message-ID: <20170417.125542.69056178938392687.davem@davemloft.net>
References: <20170412203103.6057-1-hauke@hauke-m.de>
        <20170412203103.6057-4-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jarod@redhat.com, jogo@openwrt.org, david.heidelberger@ixit.cz,
        maillist-linux@barfooze.de, mikko.rapeli@iki.fi,
        dwmw2@infradead.org
To: hauke@hauke-m.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170412203103.6057-4-hauke@hauke-m.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hauke Mehrtens <hauke@hauke-m.de>
Date: Wed, 12 Apr 2017 22:31:02 +0200

> __USE_MISC is glibc specific and not available in musl libc. Only do
> this check when glibc is used. This fixes a problem with musl libc.
> 
> Acked-by: Mikko Rapeli <mikko.rapeli@iki.fi>
> Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>

You yourself introduce this problem in patch #1.

The code before patch #1 was perfectly fine, as this code block only
existing in an area protected by __GLIBC__.

So you have to redo these patches such that you deal with all of
the fallout from changing __GLIBC__ into !__KERNEL__ at the same
time that you make that change.

Thanks.
