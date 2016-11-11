From: Yotam Gigi <yotamg@mellanox.com>
Subject: RE: [patch net-next 5/8] Introduce sample tc action
Date: Fri, 11 Nov 2016 16:34:12 +0000
Message-ID: <DB3PR05MB076471C7EA6C36C3A4A02F2EACBB0@DB3PR05MB0764.eurprd05.prod.outlook.com>
References: <1478776988-5400-1-git-send-email-jiri@resnulli.us>
 <1478776988-5400-6-git-send-email-jiri@resnulli.us>
 <5824CBFE.5030502@gmail.com> <5824CCB0.4090302@gmail.com>
 <DB3PR05MB0764850867353EEB018FCA5FACBB0@DB3PR05MB0764.eurprd05.prod.outlook.com>
 <20161111124353.GA31511@penelope.isobedori.kobe.vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
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
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0069.outbound.protection.outlook.com ([104.47.2.69]:4704
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S933831AbcKKRGy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 11 Nov 2016 12:06:54 -0500
In-Reply-To: <20161111124353.GA31511@penelope.isobedori.kobe.vergenet.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Simon Horman [mailto:simon.horman@netronome.com]
>Sent: Friday, November 11, 2016 2:44 PM
>To: Yotam Gigi <yotamg@mellanox.com>
>Cc: John Fastabend <john.fastabend@gmail.com>; Jiri Pirko <jiri@resnulli.u=
s>;
>netdev@vger.kernel.org; davem@davemloft.net; Ido Schimmel
><idosch@mellanox.com>; Elad Raz <eladr@mellanox.com>; Nogah Frankel
><nogahf@mellanox.com>; Or Gerlitz <ogerlitz@mellanox.com>;
>jhs@mojatatu.com; geert+renesas@glider.be; stephen@networkplumber.org;
>xiyou.wangcong@gmail.com; linux@roeck-us.net; roopa@cumulusnetworks.com
>Subject: Re: [patch net-next 5/8] Introduce sample tc action
>
>On Fri, Nov 11, 2016 at 08:28:50AM +0000, Yotam Gigi wrote:
>
>...
>
>> John, as a result of your question I realized that our hardware does do
>> randomized sampling that I was not aware of. I will use the extensibilit=
y of
>> the API and implement a random keyword, that will be offloaded in our
>> hardware. Those changes will be sent on v2.
>>
>> Eventually, your question was very relevant :) Thanks!
>
>Perhaps I am missing the point but why not just make random the default an=
d
>implement the inverse as an extension if it turns out to be needed in
>future?

It makes sense. It does seem to me that the average user does prefer random
sampling over deterministic one.=20

We will consider that. Thanks for the comment!
