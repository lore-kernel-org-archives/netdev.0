From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/2] bridge: use br_port_get_rtnl within rtnl
 lock
Date: Sat, 14 Sep 2013 11:46:58 -0700
Message-ID: <1379184418.24408.45.camel@edumazet-glaptop>
References: <1379169748-767-1-git-send-email-zhiguohong@tencent.com>
	 <1379169748-767-2-git-send-email-zhiguohong@tencent.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, vyasevic@redhat.com,
	Hong Zhiguo <zhiguohong@tencent.com>
To: Hong Zhiguo <honkiko@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:39154 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756702Ab3INSrA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Sep 2013 14:47:00 -0400
Received: by mail-pd0-f177.google.com with SMTP id y10so2527970pdj.36
        for <netdev@vger.kernel.org>; Sat, 14 Sep 2013 11:46:59 -0700 (PDT)
In-Reply-To: <1379169748-767-2-git-send-email-zhiguohong@tencent.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-09-14 at 22:42 +0800, Hong Zhiguo wrote:
> From: Hong Zhiguo <zhiguohong@tencent.com>
> 
> current br_port_get_rcu is problematic in bridging path
> (NULL deref). Change these calls in netlink path first.
> 
> Signed-off-by: Hong Zhiguo <zhiguohong@tencent.com>
> ---
>  net/bridge/br_netlink.c | 4 ++--
>  net/bridge/br_private.h | 2 +-
>  2 files changed, 3 insertions(+), 3 deletions(-)

Acked-by: Eric Dumazet <edumazet@google.com>

This is not net-next patch, but suitable for net tree, as the following
one fixes a potential panic.
