From: Joe Perches <joe@perches.com>
Subject: Re: pktgen IP address stepping
Date: Thu, 16 Dec 2010 10:02:12 -0800
Message-ID: <1292522532.29894.33.camel@Joe-Laptop>
References: <20101216172800.GA8404@spritelink.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Kristian Larsson <kristian@spritelink.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2713 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752620Ab0LPSCQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Dec 2010 13:02:16 -0500
In-Reply-To: <20101216172800.GA8404@spritelink.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-12-16 at 18:28 +0100, Kristian Larsson wrote:
> This patch adds the ability to set the step rate at which the source
> or destination IP address is increased when src_min / src_max or
> dst_min / dst_max is used with pktgen.
> Usage is simple, two new parameters:
>   src_step X
>   dst_step X
> where X is a positive integer (or actually an unsigned long long).
[]
> Looking forward to any feedback and / or suggestions.

I suggest using actual ipv4 addresses (and ipv6 if you ever
need it) as increment/mask.

For your current use, __u32 would work fine.

trivia:

pr_<foo> calls are already prefixed with pktgen via pr_fmt,
you don't need to add it to the format string.


