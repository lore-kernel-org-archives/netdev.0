From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] driver/net: remove unused code in cosa module
Date: Mon, 14 Apr 2014 13:31:00 -0400 (EDT)
Message-ID: <20140414.133100.2108506432746999980.davem@davemloft.net>
References: <1397470116-19669-1-git-send-email-zhen-hual@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kas@fi.muni.cz, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: zhen-hual@hp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1397470116-19669-1-git-send-email-zhen-hual@hp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Li, Zhen-Hua" <zhen-hual@hp.com>
Date: Mon, 14 Apr 2014 18:08:36 +0800

> For the cosa module, CONFIG_COSA can only be checked as 'm',
> and cosa module can only be compiled as a module.

That's not true, it's "tristate" in drivers/net/wan/Kconfig so it
could be set to 'y' too.

But there is another reason to make this change, because for such
large timeout values only msleep() makes sense, udelay() could
overflow it's internal precision.

Please resubmit this with the proper reasoning and commit message.
