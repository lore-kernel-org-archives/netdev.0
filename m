From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH net-next] tcp: diag: add support for request sockets to tcp_abort()
Date: Fri, 18 Dec 2015 17:38:42 +0900
Message-ID: <CAKD1Yr11jzdP3hfK3qk+-mkOV1Pc3DCi+Pmf=noT3SDJP6ZTGA@mail.gmail.com>
References: <1450397651.8474.110.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f174.google.com ([209.85.160.174]:36014 "EHLO
	mail-yk0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752652AbbLRIjD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2015 03:39:03 -0500
Received: by mail-yk0-f174.google.com with SMTP id x184so50431616yka.3
        for <netdev@vger.kernel.org>; Fri, 18 Dec 2015 00:39:02 -0800 (PST)
In-Reply-To: <1450397651.8474.110.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 18, 2015 at 9:14 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> Adding support for SYN_RECV request sockets to tcp_abort()
> is quite easy after our tcp listener rewrite.

I added test coverage for this to our tests.

Without this patch, attempting to destroy an SYN_RECV socket using
SOCK_DESTROY results in EOPNOTSUPP. With this patch, SOCK_DESTROY
succeeds, and after it does, sock_diag reports no child sockets.

Tested-by: Lorenzo Colitti <lorenzo@google.com>
