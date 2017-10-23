From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] add a set of tracepoints to tcp stack
Date: Mon, 23 Oct 2017 05:08:36 +0100 (WEST)
Message-ID: <20171023.050836.1983843564876160779.davem@davemloft.net>
References: <20171020212046.577888-1-songliubraving@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
        liu.song.a23@gmail.com
To: songliubraving@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41258 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750723AbdJWEIm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 00:08:42 -0400
In-Reply-To: <20171020212046.577888-1-songliubraving@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Song Liu <songliubraving@fb.com>
Date: Fri, 20 Oct 2017 14:20:40 -0700

> These patches add the following tracepoints to tcp stack.
> 
> tcp_send_reset
> tcp_receive_reset
> tcp_destroy_sock
> tcp_set_state

Please fix this build error, it probably happens when IPV6 is built
modular:

ERROR: "__tracepoint_tcp_send_reset" [net/ipv6/ipv6.ko] undefined!
scripts/Makefile.modpost:91: recipe for target '__modpost' failed

Thanks.
