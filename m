From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [patch net-next 5/8] Introduce sample tc action
Date: Fri, 11 Nov 2016 13:43:54 +0100
Message-ID: <20161111124353.GA31511@penelope.isobedori.kobe.vergenet.net>
References: <1478776988-5400-1-git-send-email-jiri@resnulli.us>
 <1478776988-5400-6-git-send-email-jiri@resnulli.us>
 <5824CBFE.5030502@gmail.com>
 <5824CCB0.4090302@gmail.com>
 <DB3PR05MB0764850867353EEB018FCA5FACBB0@DB3PR05MB0764.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Fastabend <john.fastabend@gmail.com>,
        Jiri Pirko <jiri@resnulli.us>,
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
To: Yotam Gigi <yotamg@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:37922 "EHLO
        mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754978AbcKKMn7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Nov 2016 07:43:59 -0500
Received: by mail-wm0-f50.google.com with SMTP id f82so89963423wmf.1
        for <netdev@vger.kernel.org>; Fri, 11 Nov 2016 04:43:58 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <DB3PR05MB0764850867353EEB018FCA5FACBB0@DB3PR05MB0764.eurprd05.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 11, 2016 at 08:28:50AM +0000, Yotam Gigi wrote:

...

> John, as a result of your question I realized that our hardware does do
> randomized sampling that I was not aware of. I will use the extensibility of
> the API and implement a random keyword, that will be offloaded in our
> hardware. Those changes will be sent on v2.
>
> Eventually, your question was very relevant :) Thanks!

Perhaps I am missing the point but why not just make random the default and
implement the inverse as an extension if it turns out to be needed in
future?
