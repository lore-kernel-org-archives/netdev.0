From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 5/8] Introduce sample tc action
Date: Fri, 11 Nov 2016 12:47:49 -0500 (EST)
Message-ID: <20161111.124749.1076137706092759635.davem@davemloft.net>
References: <DB3PR05MB0764850867353EEB018FCA5FACBB0@DB3PR05MB0764.eurprd05.prod.outlook.com>
        <20161111124353.GA31511@penelope.isobedori.kobe.vergenet.net>
        <5825DB2F.1090208@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: simon.horman@netronome.com, yotamg@mellanox.com, jiri@resnulli.us,
        netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
        nogahf@mellanox.com, ogerlitz@mellanox.com, jhs@mojatatu.com,
        geert+renesas@glider.be, stephen@networkplumber.org,
        xiyou.wangcong@gmail.com, linux@roeck-us.net,
        roopa@cumulusnetworks.com
To: john.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57340 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755503AbcKKRry (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Nov 2016 12:47:54 -0500
In-Reply-To: <5825DB2F.1090208@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>
Date: Fri, 11 Nov 2016 06:52:31 -0800

> On 16-11-11 04:43 AM, Simon Horman wrote:
>> On Fri, Nov 11, 2016 at 08:28:50AM +0000, Yotam Gigi wrote:
>> 
>> ...
>> 
>>> John, as a result of your question I realized that our hardware does do
>>> randomized sampling that I was not aware of. I will use the extensibility of
>>> the API and implement a random keyword, that will be offloaded in our
>>> hardware. Those changes will be sent on v2.
>>>
>>> Eventually, your question was very relevant :) Thanks!
>> 
>> Perhaps I am missing the point but why not just make random the default and
>> implement the inverse as an extension if it turns out to be needed in
>> future?
>> 
> 
> +1 just implement the random one.

Agreed.
