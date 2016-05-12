From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: mvneta: bm: fix dependencies again
Date: Thu, 12 May 2016 16:57:27 -0400 (EDT)
Message-ID: <20160512.165727.1632623842392504859.davem@davemloft.net>
References: <1462997636-1049487-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregory.clement@free-electrons.com, paul.gortmaker@windriver.com,
	mw@semihalf.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462997636-1049487-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 11 May 2016 22:13:23 +0200

> I tried to fix this before, but my previous fix was incomplete
> and we can still get the same link error in randconfig builds
> because of the way that Kconfig treats the
> 
> 	default y if MVNETA=y && MVNETA_BM_ENABLE
> 
> line that does not actually trigger when MVNETA_BM_ENABLE=m,
> unlike I intended.
> Changing the line to use MVNETA_BM_ENABLE!=n however has
> the desired effect and hopefully makes all configurations
> work as expected.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: 019ded3aa7c9 ("net: mvneta: bm: clarify dependencies")

Applied.
