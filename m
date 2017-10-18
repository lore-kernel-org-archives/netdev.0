From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH v2 net-next] tcp: Check daddr_cache before use in
 tracepoint
Date: Wed, 18 Oct 2017 08:54:10 -0600
Message-ID: <8f1c0c37-e39d-de47-f4f8-5d76e36ddfb1@gmail.com>
References: <1508193127-17626-1-git-send-email-dsahern@gmail.com>
 <20171018.141540.2101290573491932828.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:51435 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751108AbdJROyM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 10:54:12 -0400
Received: by mail-pg0-f68.google.com with SMTP id p9so4463400pgc.8
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 07:54:11 -0700 (PDT)
In-Reply-To: <20171018.141540.2101290573491932828.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/18/17 7:15 AM, David Miller wrote:
> From: David Ahern <dsahern@gmail.com>
> Date: Mon, 16 Oct 2017 15:32:07 -0700
> 
>> Running perf in one window to capture tcp_retransmit_skb tracepoint:
>>     $ perf record -e tcp:tcp_retransmit_skb -a
>>
>> And causing a retransmission on an active TCP session (e.g., dropping
>> packets in the receiver, changing MTU on the interface to 500 and back
>> to 1500) triggers a panic:
>  ...
>> Check that daddr_cache is non-NULL before de-referencing.
>>
>> Fixes: e086101b150a ("tcp: add a tracepoint for tcp retransmission")
>> Signed-off-by: David Ahern <dsahern@gmail.com>
> 
> Applied.
> 

Hi Dave: There was a v3 to this one. I'll send a diff patch.
