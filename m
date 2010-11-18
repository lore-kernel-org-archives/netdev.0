From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4] net: caif: spi: fix potential NULL dereference
Date: Thu, 18 Nov 2010 10:36:18 -0800 (PST)
Message-ID: <20101118.103618.102550300.davem@davemloft.net>
References: <1290104226-31428-1-git-send-email-segoon@openwall.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, sjur.brandeland@stericsson.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: segoon@openwall.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1290104226-31428-1-git-send-email-segoon@openwall.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vasiliy Kulikov <segoon@openwall.com>
Date: Thu, 18 Nov 2010 21:17:05 +0300

> alloc_netdev() is not checked here for NULL return value.  dev is
> check instead.  It might lead to NULL dereference of ndev.
> 
> Signed-off-by: Vasiliy Kulikov <segoon@openwall.com>
> ---
>  Compile tested.
>  Maybe dev is also must be checked here, but it looks like a trivial typo.

Definitely looks correct to me, applied, thanks!
