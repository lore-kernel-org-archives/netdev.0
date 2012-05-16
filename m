From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] net: mac80211: Neaten debugging
Date: Wed, 16 May 2012 01:23:19 -0400 (EDT)
Message-ID: <20120516.012319.1903390658912592000.davem@davemloft.net>
References: <1337106548.15553.8.camel@jlt3.sipsolutions.net>
	<cover.1337116578.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, linville@tuxdriver.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1337116578.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Tue, 15 May 2012 14:20:29 -0700

> Always use pr_debug variants instead of printk(KERN_DEBUG...)
> 
> Joe Perches (3):
>   net: mac80211: Convert printk(KERN_DEBUG to pr_debug
>   net: mac80211: Add and use ht_vdbg debugging macro
>   net: mac80211: Add and use ibss_vdbg debugging macro

I really think this is the right thing to do and I hope the wireless
folks integrate this.

I am well aware that you guys intend for some of these messages to be
indications and notifications the user is intended to SEE, but in the
cases where that is true KERN_DEBUG is absolutely not appropriate.

You should be using KERN_INFO or KERN_WARN in those situations
instead.

Thanks.
