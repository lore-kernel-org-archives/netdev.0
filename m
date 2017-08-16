From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH 0/2] bpf: sockmap build fixes
Date: Wed, 16 Aug 2017 15:58:58 -0700
Message-ID: <5994CE32.3050804@gmail.com>
References: <20170816220049.25438.62373.stgit@john-Precision-Tower-5810>        <20170816.153516.1392924482619263360.davem@davemloft.net> <20170816.154204.2107336943249325947.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, eric.dumazet@gmail.com, dsahern@gmail.com,
        netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:37595 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752441AbdHPW7M (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 18:59:12 -0400
Received: by mail-pg0-f49.google.com with SMTP id y129so30164905pgy.4
        for <netdev@vger.kernel.org>; Wed, 16 Aug 2017 15:59:12 -0700 (PDT)
In-Reply-To: <20170816.154204.2107336943249325947.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/16/2017 03:42 PM, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Wed, 16 Aug 2017 15:35:16 -0700 (PDT)
> 
>> From: John Fastabend <john.fastabend@gmail.com>
>> Date: Wed, 16 Aug 2017 15:01:52 -0700
>>
>>> Two build fixes for sockmap, this should resolve the build errors
>>> and warnings that were reported. Thanks everyone.
>>
>> Series applied, thanks John.
> 
> Actually, now there is a new problem:
> 
> ERROR: "tcp_sendpage_locked" [net/ipv6/ipv6.ko] undefined!
> ERROR: "tcp_sendmsg_locked" [net/ipv6/ipv6.ko] undefined!
> make[1]: *** [scripts/Makefile.modpost:91: __modpost] Error 1
> make: *** [Makefile:1217: modules] Error 2
> 
> I added GPL exports for these, but please do an allmodconfig
> build before you submit anything to me when there are weird
> inter-module dependencies like this.
> 
> Thanks.
> 

Thanks and allmodconfig noted.
