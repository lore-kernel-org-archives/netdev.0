From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [patch net-next 5/8] Introduce sample tc action
Date: Fri, 11 Nov 2016 06:52:31 -0800
Message-ID: <5825DB2F.1090208@gmail.com>
References: <1478776988-5400-1-git-send-email-jiri@resnulli.us>
 <1478776988-5400-6-git-send-email-jiri@resnulli.us>
 <5824CBFE.5030502@gmail.com> <5824CCB0.4090302@gmail.com>
 <DB3PR05MB0764850867353EEB018FCA5FACBB0@DB3PR05MB0764.eurprd05.prod.outlook.com>
 <20161111124353.GA31511@penelope.isobedori.kobe.vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        Ido Schimmel <idosch@mellanox.com>,
        Elad Raz <eladr@mellanox.com>,
        Nogah Frankel <nogahf@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        "jhs@mojatatu.com" <jhs@mojatatu.com>,
        "geert+renesas@glider.be" <geert+renesas@glider.be>,
        "stephen@networkplumber.org" <stephen@networkplumber.org>,
        "xiyou.wangcong@gmail.com" <xiyou.wangcong@gmail.com>,
        "linux@roeck-us.net" <linux@roeck-us.net>,
        "roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>
To: Simon Horman <simon.horman@netronome.com>,
        Yotam Gigi <yotamg@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:36497 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752140AbcKKO6m (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Nov 2016 09:58:42 -0500
Received: by mail-pg0-f44.google.com with SMTP id f188so13744447pgc.3
        for <netdev@vger.kernel.org>; Fri, 11 Nov 2016 06:58:41 -0800 (PST)
In-Reply-To: <20161111124353.GA31511@penelope.isobedori.kobe.vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-11-11 04:43 AM, Simon Horman wrote:
> On Fri, Nov 11, 2016 at 08:28:50AM +0000, Yotam Gigi wrote:
> 
> ...
> 
>> John, as a result of your question I realized that our hardware does do
>> randomized sampling that I was not aware of. I will use the extensibility of
>> the API and implement a random keyword, that will be offloaded in our
>> hardware. Those changes will be sent on v2.
>>
>> Eventually, your question was very relevant :) Thanks!
> 
> Perhaps I am missing the point but why not just make random the default and
> implement the inverse as an extension if it turns out to be needed in
> future?
> 

+1 just implement the random one.

.John
