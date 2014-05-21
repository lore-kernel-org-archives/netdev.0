From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ieee802154: Introduce the use of the managed
 version of kzalloc
Date: Wed, 21 May 2014 16:30:27 -0400 (EDT)
Message-ID: <20140521.163027.379421150593976730.davem@davemloft.net>
References: <20140519165511.GA8966@himangi-Dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, julia.lawall@lip6.fr
To: himangi774@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140519165511.GA8966@himangi-Dell>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Himangi Saraogi <himangi774@gmail.com>
Date: Mon, 19 May 2014 22:25:11 +0530

> This patch moves data allocated using kzalloc to managed data allocated
> using devm_kzalloc and cleans now unnecessary kfrees in probe and remove
> functions. An explicit linux/device.h include is added to make sure
> the devm_*() routine declarations are unambiguously available.
> 
> The following Coccinelle semantic patch was used for making the change:
 ...
> Signed-off-by: Himangi Saraogi <himangi774@gmail.com>
> Acked-by: Julia Lawall <julia.lawall@lip6.fr>
> ---
> v2: add explicit include for linux/device.h

Applied, thank you.
