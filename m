From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] softirq: let ksoftirqd do its job
Date: Wed, 31 Aug 2016 15:27:30 -0700
Message-ID: <1472682450.14381.364.camel@edumazet-glaptop3.roam.corp.google.com>
References: <4f1c4b38528762619fff1fa963de8971006c1234.1472460085.git.pabeni@redhat.com>
         <20160831100854.23dad2d8@redhat.com>
         <1472650472.14381.317.camel@edumazet-glaptop3.roam.corp.google.com>
         <1472650688.32433.115.camel@redhat.com>
         <1472652643.14381.320.camel@edumazet-glaptop3.roam.corp.google.com>
         <20160831164216.2901190c@redhat.com>
         <1472661956.14381.335.camel@edumazet-glaptop3.roam.corp.google.com>
         <1472665349.14381.356.camel@edumazet-glaptop3.roam.corp.google.com>
         <20160831214043.2f44cf08@redhat.com>
         <1472676150.14381.363.camel@edumazet-glaptop3.roam.corp.google.com>
         <20160831235116.33b1946b@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Peter Zijlstra <peterz@infradead.org>,
        David Miller <davem@davemloft.net>,
        Rik van Riel <riel@redhat.com>,
        Paolo Abeni <pabeni@redhat.com>,
        Hannes Frederic Sowa <hannes@redhat.com>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>, Jonathan Corbet <corbet@lwn.net>
To: Jesper Dangaard Brouer <jbrouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33090 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753993AbcHaW1d (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2016 18:27:33 -0400
In-Reply-To: <20160831235116.33b1946b@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-08-31 at 23:51 +0200, Jesper Dangaard Brouer wrote:

> 
> The result from this run were handling 1,517,248 pps, without any
> drops, all processes pinned to the same CPU.
> 
>  $ nstat > /dev/null && sleep 1 && nstat
>  #kernel
>  IpInReceives                    1517225            0.0
>  IpInDelivers                    1517224            0.0
>  UdpInDatagrams                  1517248            0.0
>  IpExtInOctets                   69793408           0.0
>  IpExtInNoECTPkts                1517246            0.0
> 
> I'm acking this patch:
> 
> Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>
> 

Thanks a lot for bringing back the issue to me again, and all your
tests !
