From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the final tree (net
 tree related)
Date: Mon, 27 Sep 2010 01:17:32 -0700 (PDT)
Message-ID: <20100927.011732.42806207.davem@davemloft.net>
References: <20100927154408.55a28127.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, ohad@wizery.com,
	linville@tuxdriver.com
To: sfr@canb.auug.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100927154408.55a28127.sfr@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Mon, 27 Sep 2010 15:44:08 +1000

> After merging the final tree, today's linux-next build (x86_64
> allmodconfig) failed like this:
> 
> Assembler messages:
> Fatal error: can't create drivers/net/wireless/wl12xx/.tmp_wl12xx_platform_data.o: No such file or directory
> drivers/net/wireless/wl12xx/wl12xx_platform_data.c: In function 'wl12xx_get_platform_data':
> drivers/net/wireless/wl12xx/wl12xx_platform_data.c:28: error: cannot open drivers/net/wireless/wl12xx/.tmp_wl12xx_platform_data.gcno
> drivers/net/wireless/wl12xx/wl12xx_platform_data.c:28: confused by earlier errors, bailing out
> 
> Presumably caused by commit 61ee7007a5d61aa066076da578e8e8084e122d7d
> ("wl12xx: add platform data passing support").
> 
> I do my builds with a separate object directory (which may be a reason
> you don't see this).

John, please get this fixed, thanks.
