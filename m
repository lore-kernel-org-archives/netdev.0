From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: sfc: avoid -Wtype-limits warning
Date: Thu, 16 Jun 2016 14:24:24 -0700 (PDT)
Message-ID: <20160616.142424.302149364592568497.davem@davemloft.net>
References: <20160615203122.3574513-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com, ecree@solarflare.com,
	bkenward@solarflare.com, mhabets@solarflare.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160615203122.3574513-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 15 Jun 2016 22:31:10 +0200

> When building with -Wextra, we get a harmless warning from the
> EFX_EXTRACT_OWORD32 macro:
> 
> ethernet/sfc/farch.c: In function 'efx_farch_test_registers':
> ethernet/sfc/farch.c:119:30: error: comparison of unsigned expression < 0 is always false [-Werror=type-limits]
> ethernet/sfc/farch.c:124:144: error: comparison of unsigned expression < 0 is always false [-Werror=type-limits]
> ethernet/sfc/farch.c:124:392: error: comparison of unsigned expression < 0 is always false [-Werror=type-limits]
> ethernet/sfc/farch.c:124:731: error: comparison of unsigned expression < 0 is always false [-Werror=type-limits]
> 
> The macro and the caller are both correct, but we can avoid the
> warning by changing the index variable to a signed type.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied, thanks.
