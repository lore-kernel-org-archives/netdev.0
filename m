From: Vasiliy Kulikov <segoon@openwall.com>
Subject: Re: [PATCH net-next-2.6] net: ping: small changes
Date: Sat, 14 May 2011 18:34:05 +0400
Message-ID: <20110514143405.GA7599@albatros>
References: <1305363559.3120.54.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:40100 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757936Ab1ENOeN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 May 2011 10:34:13 -0400
Received: by bwz15 with SMTP id 15so2755702bwz.19
        for <netdev@vger.kernel.org>; Sat, 14 May 2011 07:34:12 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1305363559.3120.54.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 14, 2011 at 10:59 +0200, Eric Dumazet wrote:
> ping_table is not __read_mostly, since it contains one rwlock,
> and is static to ping.c
> 
> ping_port_rover & ping_v4_lookup are static
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Acked-by: Vasiliy Kulikov <segoon@openwall.com>

Thanks,

-- 
Vasiliy Kulikov
http://www.openwall.com - bringing security into open computing environments
