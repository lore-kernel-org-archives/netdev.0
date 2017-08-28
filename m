From: David Ahern <dsahern@gmail.com>
Subject: Re: IPv6 loopback issue report
Date: Mon, 28 Aug 2017 09:07:20 -0600
Message-ID: <47ca5f63-de49-d9fe-f8f7-08240206627a@gmail.com>
References: <464e900f-c256-4d22-6a83-a3aea0fca8bc@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: ranro@mellanox.com, guye@mellanox.com,
        Eran Ben Elisha <eranbe@mellanox.com>
To: Tariq Toukan <tariqt@mellanox.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:33206 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751232AbdH1PHT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 11:07:19 -0400
Received: by mail-pf0-f176.google.com with SMTP id r62so2095833pfj.0
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 08:07:19 -0700 (PDT)
In-Reply-To: <464e900f-c256-4d22-6a83-a3aea0fca8bc@mellanox.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/28/17 8:48 AM, Tariq Toukan wrote:
> #  /bin/ping6 -c 3 fe80::7efe:90ff:fecb:7502%ens8
> PING fe80::7efe:90ff:fecb:7502%ens8(fe80::7efe:90ff:fecb:7502) 56 data
> bytes
> 
> --- fe80::7efe:90ff:fecb:7502%ens8 ping statistics ---
> 3 packets transmitted, 0 received, 100% packet loss, time 2043ms


I'll take a look. Most likely related to my recent IPv6 change.
