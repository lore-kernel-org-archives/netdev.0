From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 08/14] gtp: Support encpasulating over IPv6
Date: Wed, 20 Sep 2017 12:45:11 -0700 (PDT)
Message-ID: <20170920.124511.922311380432026759.davem@davemloft.net>
References: <20170919003904.5124-9-tom@quantonium.net>
        <20170918.211952.1397675528248642600.davem@davemloft.net>
        <CALx6S36cJEU2LkbNf-d8kUHCPj78bt5Y2Bd_rdvjxJ9epOEqAQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom@quantonium.net, netdev@vger.kernel.org, pablo@netfilter.org,
        laforge@gnumonks.org, rohit@quantonium.net
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34656 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751000AbdITTpO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 15:45:14 -0400
In-Reply-To: <CALx6S36cJEU2LkbNf-d8kUHCPj78bt5Y2Bd_rdvjxJ9epOEqAQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Wed, 20 Sep 2017 11:03:52 -0700

> On Mon, Sep 18, 2017 at 9:19 PM, David Miller <davem@davemloft.net> wrote:
>> From: Tom Herbert <tom@quantonium.net>
>> Date: Mon, 18 Sep 2017 17:38:58 -0700
>>
>>> Allow peers to be specified by IPv6 addresses.
>>>
>>> Signed-off-by: Tom Herbert <tom@quantonium.net>
>>
>> Hmmm, can you just check the socket family or something like that?
> 
> I'm not sure what code you're referring to.

There is a socket associated with the tunnel to do the encapsulation
and it has an address family, right?
