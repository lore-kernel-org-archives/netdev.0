From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: mdio-sun4i: Convert to devm_* api
Date: Thu, 29 Aug 2013 14:55:13 -0400 (EDT)
Message-ID: <20130829.145513.179529840926907721.davem@davemloft.net>
References: <1377522717-5784-1-git-send-email-jszhang@marvell.com>
	<20130828093508.GQ2695@lukather>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jszhang@marvell.com, emilio@elopez.com.ar, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: maxime.ripard@free-electrons.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130828093508.GQ2695@lukather>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Maxime Ripard <maxime.ripard@free-electrons.com>
Date: Wed, 28 Aug 2013 11:35:08 +0200

> Hi Jisheng,
> 
> On Mon, Aug 26, 2013 at 09:11:57PM +0800, Jisheng Zhang wrote:
>> Use devm_ioremap_resource instead of of_iomap() and devm_kzalloc()
>> instead of kmalloc() to make cleanup paths simpler. This patch also
>> fixes the resource leak caused by missing corresponding iounamp()
>> of the of_iomap().
>> 
>> Signed-off-by: Jisheng Zhang <jszhang@marvell.com>
> 
> It looks fine for me.
> Acked-by: Maxime Ripard <maxime.ripard@free-electrons.com>

Applied to net-next, thanks.
