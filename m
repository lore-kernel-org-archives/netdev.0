From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] qed: select ZLIB_INFLATE
Date: Tue, 10 Nov 2015 15:39:24 -0500 (EST)
Message-ID: <20151110.153924.2077785007530529512.davem@davemloft.net>
References: <4747865.4UjGACl7bb@wuerfel>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Yuval.Mintz@qlogic.com,
	Ariel.Elior@qlogic.com, everest-linux-l2@qlogic.com,
	netdev@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4747865.4UjGACl7bb@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Tue, 10 Nov 2015 11:28:15 +0100

> The newly added qlogic qed driver uses the zlib library, but
> misses the dependency:
> 
> drivers/built-in.o: In function `qed_alloc_stream_mem':
> drivers/net/ethernet/qlogic/qed/qed_main.c:707: undefined reference to `zlib_inflate_workspacesize'
> drivers/built-in.o: In function `qed_unzip_data':
> drivers/net/ethernet/qlogic/qed/qed_main.c:675: undefined reference to `zlib_inflateInit2'
> 
> This changes Kconfig to always select zlib when needed.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: fe56b9e6a8d9 ("qed: Add module with basic common support")
> ---
> Found on ARM randconfig builds

Applied, thanks.
