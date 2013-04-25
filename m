From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next v3 3/4] sock_diag: do not disclose sock ptr to
 all users
Date: Thu, 25 Apr 2013 18:45:09 +0200
Message-ID: <51795D95.9090904@6wind.com>
References: <20130425.050008.2129680886418162075.davem@davemloft.net>  <1366896111-4436-1-git-send-email-nicolas.dichtel@6wind.com>  <1366896111-4436-4-git-send-email-nicolas.dichtel@6wind.com>  <1366903930.8964.154.camel@edumazet-glaptop> <1366904177.8964.155.camel@edumazet-glaptop>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, xiyou.wangcong@gmail.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:50822 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758917Ab3DYQpP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 12:45:15 -0400
Received: by mail-wi0-f174.google.com with SMTP id m6so8922040wiv.7
        for <netdev@vger.kernel.org>; Thu, 25 Apr 2013 09:45:14 -0700 (PDT)
In-Reply-To: <1366904177.8964.155.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 25/04/2013 17:36, Eric Dumazet a =C3=A9crit :
> On Thu, 2013-04-25 at 08:32 -0700, Eric Dumazet wrote:
>
>> Nack. This was already discussed in the past.
>>
>> Some people don't want to dump whole table, but use cookie to dump a
>> particular socket.
>
> For more details :
>
> git grep -n sock_diag_check_cookie
> include/linux/sock_diag.h:21:int sock_diag_check_cookie(void *sk, __u=
32 *cookie);
> net/core/sock_diag.c:16:int sock_diag_check_cookie(void *sk, __u32 *c=
ookie)
> net/core/sock_diag.c:26:EXPORT_SYMBOL_GPL(sock_diag_check_cookie);
> net/ipv4/inet_diag.c:312:       err =3D sock_diag_check_cookie(sk, re=
q->id.idiag_cookie);
> net/ipv4/udp_diag.c:62: err =3D sock_diag_check_cookie(sk, req->id.id=
iag_cookie);
> net/unix/diag.c:259:    err =3D sock_diag_check_cookie(sk, req->udiag=
_cookie);
I definitely miss the thread about this topic, I will try to find it.
