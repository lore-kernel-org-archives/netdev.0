From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 6lowpan: add a license to 6lowpan_iphc module
Date: Wed, 22 Jan 2014 21:59:44 -0800 (PST)
Message-ID: <20140122.215944.1857286066071533638.davem@davemloft.net>
References: <1390418724-9804-1-git-send-email-ydroneaud@opteya.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	marcel@holtmann.org, gustavo@padovan.org, johan.hedberg@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jukka.rissanen@linux.intel.com,
	alex.aring@gmail.com
To: ydroneaud@opteya.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1390418724-9804-1-git-send-email-ydroneaud@opteya.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yann Droneaud <ydroneaud@opteya.com>
Date: Wed, 22 Jan 2014 20:25:24 +0100

> Since commit 8df8c56a5abc, 6lowpan_iphc is a module of its own.
> 
> Unfortunately, it lacks some infrastructure to behave like a
> good kernel citizen:
> 
>   kernel: 6lowpan_iphc: module license 'unspecified' taints kernel.
>   kernel: Disabling lock debugging due to kernel taint
> 
> This patch adds the basic MODULE_LICENSE(); with GPL license:
> the code was copied from net/ieee802154/6lowpan.c which is GPL
> and the module exports symbol with EXPORT_SYMBOL_GPL();.
> 
> Cc: Jukka Rissanen <jukka.rissanen@linux.intel.com>
> Cc: Alexander Aring <alex.aring@gmail.com>
> Cc: Marcel Holtmann <marcel@holtmann.org>
> Signed-off-by: Yann Droneaud <ydroneaud@opteya.com>

Applied.
