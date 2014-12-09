From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/9] r8169:update hardware ephy parameter
Date: Tue, 09 Dec 2014 18:35:49 -0500 (EST)
Message-ID: <20141209.183549.1930188640715074097.davem@davemloft.net>
References: <1418143563-7652-1-git-send-email-hau@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org
To: hau@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1418143563-7652-1-git-send-email-hau@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chunhao Lin <hau@realtek.com>
Date: Wed, 10 Dec 2014 00:45:54 +0800

> Update hardware ephy parameter to improve pcie compatibility.

This really doesn't tell me anything, I really dislike patch
series like this one.

All of the programming is magic values to magic offsets.

You aren't even trying to describe in the commit log message exactly
what kind of settings are being changed, and exactly how those changes
achieve the stated goal.

Furthermore, the commit description makes no sense at all to me.

How can programming the ethernet MAC PHY have any influence on PCI-E
bus compatability?  Or are you programming the PCI bus interface's
PHY?

In what way are you adjusting which settings and in what way do those
adjustments help improve PCI-E bus behavior?

You absolutely must describe exactly what the new programming
is actually doing, precisely, and in detail.  I want to know
if some kind of timings are being adjusted, and in what way.
Are some fifo limits being changes?  If so, in what way, and
why does that help.

You have to describe what you are doing. Short and non-informative
commit log messages alongside random changes to undocumented magic
constant registers is simply unacceptable.
