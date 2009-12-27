From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sky2: make sure ethernet header is in transmit skb
Date: Sat, 26 Dec 2009 19:44:18 -0800 (PST)
Message-ID: <20091226.194418.229766965.davem@davemloft.net>
References: <20091226095723.7ac82b18@nehalam>
	<4B367409.5060202@majjas.com>
	<20091226140544.5600b3d1@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mbreuer@majjas.com, akpm@linux-foundation.org, flyboy@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754675AbZL0DoT@vger.kernel.org>
In-Reply-To: <20091226140544.5600b3d1@nehalam>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Sat, 26 Dec 2009 14:05:44 -0800

> Other drivers may have same problem, I really think this ought
> to be done at higher level.

I tend to agree with you, and I thought we had handled all
cases.  Let's simply make AF_PACKET linearize the link
level header before sending things out to the transmit path.

I can work on this if you want.
