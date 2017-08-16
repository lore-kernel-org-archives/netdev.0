From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 0/2] bpf: sockmap build fixes
Date: Wed, 16 Aug 2017 15:42:04 -0700 (PDT)
Message-ID: <20170816.154204.2107336943249325947.davem@davemloft.net>
References: <20170816220049.25438.62373.stgit@john-Precision-Tower-5810>
        <20170816.153516.1392924482619263360.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, eric.dumazet@gmail.com, dsahern@gmail.com,
        netdev@vger.kernel.org
To: john.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40092 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752266AbdHPWmF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 18:42:05 -0400
In-Reply-To: <20170816.153516.1392924482619263360.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Wed, 16 Aug 2017 15:35:16 -0700 (PDT)

> From: John Fastabend <john.fastabend@gmail.com>
> Date: Wed, 16 Aug 2017 15:01:52 -0700
> 
>> Two build fixes for sockmap, this should resolve the build errors
>> and warnings that were reported. Thanks everyone.
> 
> Series applied, thanks John.

Actually, now there is a new problem:

ERROR: "tcp_sendpage_locked" [net/ipv6/ipv6.ko] undefined!
ERROR: "tcp_sendmsg_locked" [net/ipv6/ipv6.ko] undefined!
make[1]: *** [scripts/Makefile.modpost:91: __modpost] Error 1
make: *** [Makefile:1217: modules] Error 2

I added GPL exports for these, but please do an allmodconfig
build before you submit anything to me when there are weird
inter-module dependencies like this.

Thanks.
