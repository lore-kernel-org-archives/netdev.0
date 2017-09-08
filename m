From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] isdn: isdnloop: fix logic error in isdnloop_sendbuf
Date: Thu, 07 Sep 2017 20:04:30 -0700 (PDT)
Message-ID: <20170907.200430.192546025684691135.davem@davemloft.net>
References: <20170906133928.3152020-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, joe@perches.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170906133928.3152020-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Wed,  6 Sep 2017 15:38:58 +0200

> gcc-7 found an ancient bug in the loop driver, leading to a condition that
> is always false, meaning we ignore the contents of 'card->flags' here:
> 
> drivers/isdn/isdnloop/isdnloop.c:412:37: error: ?: using integer constants in boolean context, the expression will always evaluate to 'true' [-Werror=int-in-bool-context]
> 
> This changes the braces in the expression to ensure we actually
> compare the flag bits, rather than comparing a constant. As Joe Perches
> pointed out, an earlier patch of mine incorrectly assumed this was a
> false-positive warning.
> 
> Cc: Joe Perches <joe@perches.com>
> Link: https://patchwork.kernel.org/patch/9840289/
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied, thank you.
