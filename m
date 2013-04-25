From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v3 3/4] sock_diag: do not disclose sock ptr to
 all users
Date: Thu, 25 Apr 2013 08:32:10 -0700
Message-ID: <1366903930.8964.154.camel@edumazet-glaptop>
References: <20130425.050008.2129680886418162075.davem@davemloft.net>
	 <1366896111-4436-1-git-send-email-nicolas.dichtel@6wind.com>
	 <1366896111-4436-4-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, xiyou.wangcong@gmail.com,
	netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:38182 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932192Ab3DYPcN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 11:32:13 -0400
Received: by mail-pb0-f48.google.com with SMTP id xb4so822387pbc.7
        for <netdev@vger.kernel.org>; Thu, 25 Apr 2013 08:32:13 -0700 (PDT)
In-Reply-To: <1366896111-4436-4-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-04-25 at 15:21 +0200, Nicolas Dichtel wrote:
> This is a sensible info, hence we restrict the user allowed to get it.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
>  include/linux/sock_diag.h |  3 ++-
>  net/core/sock_diag.c      | 12 +++++++++---
>  net/ipv4/inet_diag.c      | 13 ++++++++-----
>  net/netlink/diag.c        |  5 ++++-
>  net/packet/diag.c         |  2 +-
>  net/unix/diag.c           | 14 +++++++++-----
>  6 files changed, 33 insertions(+), 16 deletions(-)

Nack. This was already discussed in the past.

Some people don't want to dump whole table, but use cookie to dump a
particular socket.
