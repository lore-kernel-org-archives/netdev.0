From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dnet: fix wrong use of platform_set_drvdata()
Date: Mon, 28 Feb 2011 12:22:40 -0800 (PST)
Message-ID: <20110228.122240.48503372.davem@davemloft.net>
References: <4D62C897.5020707@emcraft.com>
	<1298319630-18159-1-git-send-email-yanok@emcraft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, greg@kroah.com, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, mkl@pengutronix.de,
	netdev@vger.kernel.org
To: yanok@emcraft.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1298319630-18159-1-git-send-email-yanok@emcraft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ilya Yanok <yanok@emcraft.com>
Date: Mon, 21 Feb 2011 21:20:30 +0100

> platform_set_drvdata() was used with argument of incorrect type and
> could cause memory corruption. Moreover, because of not setting drvdata
> in the correct place not all resources were freed upon module unload.
> 
> Signed-off-by: Ilya Yanok <yanok@emcraft.com>

Applied.
