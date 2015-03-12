From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net:Kconfig: drop no sense dependence entry for BONDING
Date: Thu, 12 Mar 2015 14:15:56 -0400 (EDT)
Message-ID: <20150312.141556.780781968181122546.davem@davemloft.net>
References: <20150312135933.GA3502@udknight>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-kbuild@vger.kernel.org, j.vosburgh@gmail.com,
	vfalico@gmail.com, gospo@cumulusnetworks.com
To: udknight@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150312135933.GA3502@udknight>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Wang YanQing <udknight@gmail.com>
Date: Thu, 12 Mar 2015 21:59:33 +0800

> "IPV6 || IPV6=n" means no dependence!
> 
> Signed-off-by: Wang YanQing <udknight@gmail.com>

It is only nonsense because you don't actually understand what the
statement does.

It makes sure that either IPV6 is enabled and _EQUALS_ what BONDING is
set to ("y" _or_ "m"), or it is disabled.

This pattern is used all over the place and is quite common actually.

Better to first ask what a statement does, than to knee-jerk submit a
patch to remove it.  Because patch submissions use up people's
resources and time, particularly mine.
