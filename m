From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v3 3/4] sock_diag: do not disclose sock ptr to
 all users
Date: Thu, 25 Apr 2013 08:36:17 -0700
Message-ID: <1366904177.8964.155.camel@edumazet-glaptop>
References: <20130425.050008.2129680886418162075.davem@davemloft.net>
	 <1366896111-4436-1-git-send-email-nicolas.dichtel@6wind.com>
	 <1366896111-4436-4-git-send-email-nicolas.dichtel@6wind.com>
	 <1366903930.8964.154.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, xiyou.wangcong@gmail.com,
	netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:37391 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758205Ab3DYPgT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 11:36:19 -0400
Received: by mail-pa0-f51.google.com with SMTP id jh10so1941264pab.10
        for <netdev@vger.kernel.org>; Thu, 25 Apr 2013 08:36:18 -0700 (PDT)
In-Reply-To: <1366903930.8964.154.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-04-25 at 08:32 -0700, Eric Dumazet wrote:

> Nack. This was already discussed in the past.
> 
> Some people don't want to dump whole table, but use cookie to dump a
> particular socket.

For more details :

git grep -n sock_diag_check_cookie
include/linux/sock_diag.h:21:int sock_diag_check_cookie(void *sk, __u32 *cookie);
net/core/sock_diag.c:16:int sock_diag_check_cookie(void *sk, __u32 *cookie)
net/core/sock_diag.c:26:EXPORT_SYMBOL_GPL(sock_diag_check_cookie);
net/ipv4/inet_diag.c:312:       err = sock_diag_check_cookie(sk, req->id.idiag_cookie);
net/ipv4/udp_diag.c:62: err = sock_diag_check_cookie(sk, req->id.idiag_cookie);
net/unix/diag.c:259:    err = sock_diag_check_cookie(sk, req->udiag_cookie);
