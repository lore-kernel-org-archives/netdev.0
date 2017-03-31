From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 00/19] net: hns: Misc. HNS Bug Fixes & Code
 Improvements
Date: Thu, 30 Mar 2017 20:03:17 -0700 (PDT)
Message-ID: <20170330.200317.1176664200594872180.davem@davemloft.net>
References: <20170330153106.14344-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yisen.zhuang@huawei.com, mehta.salil.lnk@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linuxarm@huawei.com
To: salil.mehta@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170330153106.14344-1-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Salil Mehta <salil.mehta@huawei.com>
Date: Thu, 30 Mar 2017 16:30:47 +0100

> This patch set introduces various HNS bug fixes, optimizations and code
> improvements.

There is no way you should do such an expensive calculation for every
single transmit packet as you are doing in your select_queue() routine.

That's really crazy.

Just use the networking stack's queue selection scheme, or suggest
ways to improve it.  Don't do private hashing like this in your
driver, please!
