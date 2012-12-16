From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: Fix Makefile offload objects
Date: Sun, 16 Dec 2012 09:17:47 -0800 (PST)
Message-ID: <20121216.091747.271269648244929827.davem@davemloft.net>
References: <50CDFB36.1020604@simon.arlott.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	vyasevic@redhat.com
To: simon@fire.lp0.eu
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <50CDFB36.1020604@simon.arlott.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Simon Arlott <simon@fire.lp0.eu>
Date: Sun, 16 Dec 2012 16:47:50 +0000

> The following commit breaks IPv6 TCP transmission for me:
> 	Commit 75fe83c32248d99e6d5fe64155e519b78bb90481
> 	Author: Vlad Yasevich <vyasevic@redhat.com>
> 	Date:   Fri Nov 16 09:41:21 2012 +0000
> 	ipv6: Preserve ipv6 functionality needed by NET
> 
> This patch fixes the typo "ipv6_offload" which should be
> "ipv6-offload".
> 
> I don't know why not including the offload modules should
> break TCP. Disabling all offload options on the NIC didn't
> help. Outgoing pulseaudio traffic kept stalling.
> 
> Signed-off-by: Simon Arlott <simon@fire.lp0.eu>

Applied, since the fix is so obvious.

I'll let Vlad explain why it has such an unexpected
effect.

Thanks.
