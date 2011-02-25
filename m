From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: [PATCH] sysctl: ipv6: use correct net in ipv6_sysctl_rtcache_flush
Date: Fri, 25 Feb 2011 16:30:25 +0100
Message-ID: <4D67CB11.4020801@free.fr>
References: <1298612883-18762-1-git-send-email-lucian.grijincu@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>,
	Benjamin Thery <benjamin.thery@bull.net>
To: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6-g21.free.fr ([212.27.42.6]:54747 "EHLO smtp6-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752888Ab1BYPag (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Feb 2011 10:30:36 -0500
In-Reply-To: <1298612883-18762-1-git-send-email-lucian.grijincu@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/25/2011 06:48 AM, Lucian Adrian Grijincu wrote:
> Before this patch issuing these commands:
>
>    fd = open("/proc/sys/net/ipv6/route/flush")
>    unshare(CLONE_NEWNET)
>    write(fd, "stuff")
>
> would flush the newly created net, not the original one.
>
> The equivalent ipv4 code is correct (stores the net inside ->extra1).
> ---

Acked-by: Daniel Lezcano <daniel.lezcano@free.fr>
