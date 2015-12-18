From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: diag: add support for request sockets to
 tcp_abort()
Date: Fri, 18 Dec 2015 04:46:51 -0800
Message-ID: <1450442811.8474.116.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1450397651.8474.110.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAKD1Yr11jzdP3hfK3qk+-mkOV1Pc3DCi+Pmf=noT3SDJP6ZTGA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:33392 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753077AbbLRMqx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2015 07:46:53 -0500
Received: by mail-pa0-f52.google.com with SMTP id ur14so60174542pab.0
        for <netdev@vger.kernel.org>; Fri, 18 Dec 2015 04:46:53 -0800 (PST)
In-Reply-To: <CAKD1Yr11jzdP3hfK3qk+-mkOV1Pc3DCi+Pmf=noT3SDJP6ZTGA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-12-18 at 17:38 +0900, Lorenzo Colitti wrote:
> On Fri, Dec 18, 2015 at 9:14 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > Adding support for SYN_RECV request sockets to tcp_abort()
> > is quite easy after our tcp listener rewrite.
> 
> I added test coverage for this to our tests.
> 
> Without this patch, attempting to destroy an SYN_RECV socket using
> SOCK_DESTROY results in EOPNOTSUPP. With this patch, SOCK_DESTROY
> succeeds, and after it does, sock_diag reports no child sockets.
> 
> Tested-by: Lorenzo Colitti <lorenzo@google.com>

I am curious, did you use packetdrill for this ?

I was about to write a packetdrill test as well ;)

Thanks !
