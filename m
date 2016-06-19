From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 5/5] ipv6: RFC 4884 partial support for SIT/GRE
 tunnels
Date: Sat, 18 Jun 2016 21:40:00 -0700
Message-ID: <1466311200.6850.11.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1466292400-3638-6-git-send-email-edumazet@google.com>
	 <20160618.205448.2083694904305197335.davem@davemloft.net>
	 <1466309009.6850.10.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160618.212654.1904707788416158933.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org,
	ghorbel@pivasoftware.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:34996 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750720AbcFSEkE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2016 00:40:04 -0400
Received: by mail-pa0-f45.google.com with SMTP id hl6so40268383pac.2
        for <netdev@vger.kernel.org>; Sat, 18 Jun 2016 21:40:03 -0700 (PDT)
In-Reply-To: <20160618.212654.1904707788416158933.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2016-06-18 at 21:26 -0700, David Miller wrote:

> The golden rule is: "the memory areas must not overlap"
> 
> If it can be optimized into calling a memcpy, the memmove
> implementation will do so.

Of course, I guess I have been working on x86 for too long ;)
