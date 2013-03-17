From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ethernet/tulip: DE4x5 needs VIRT_TO_BUS
Date: Sun, 17 Mar 2013 12:01:40 -0400 (EDT)
Message-ID: <20130317.120140.1114222806134803996.davem@davemloft.net>
References: <1363298204-8014-1-git-send-email-arnd@arndb.de>
	<1363298204-8014-5-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	grundler@parisc-linux.org, netdev@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1363298204-8014-5-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Thu, 14 Mar 2013 22:56:42 +0100

> The automated ARM build tests have shown that the tulip de4x5 driver
> uses the old-style virt_to_bus() interface on some architectures.
> 
> Alpha, Sparc and PowerPC did not hit this problem, because they
> use a different code path, and most other architectures actually
> do provide VIRT_TO_BUS.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied.
