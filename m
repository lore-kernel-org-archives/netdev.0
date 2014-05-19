From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ieee802154: Introduce the use of the managed version
 of kzalloc
Date: Sun, 18 May 2014 20:57:26 -0400 (EDT)
Message-ID: <20140518.205726.138371667211604965.davem@davemloft.net>
References: <20140516180935.GA13004@himangi-Dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, julia.lawall@lip6.fr
To: himangi774@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140516180935.GA13004@himangi-Dell>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Himangi Saraogi <himangi774@gmail.com>
Date: Fri, 16 May 2014 23:39:35 +0530

> This patch moves data allocated using kzalloc to managed data allocated
> using devm_kzalloc and cleans now unnecessary kfrees in probe and remove
> functions.

Likewise please add an explicit linux/device.h include to make sure
the devm_*() routine declarations are unambiguously available.
