From: Yotam Gigi <yotamg@mellanox.com>
Subject: RE: [patch net-next 2/4] net/sched: Introduce sample tc action
Date: Sun, 22 Jan 2017 13:28:16 +0000
Message-ID: <DB3PR05MB07647B3EAE035276C60CCB4DAC730@DB3PR05MB0764.eurprd05.prod.outlook.com>
References: <1485085487-2652-1-git-send-email-jiri@resnulli.us>
 <1485085487-2652-3-git-send-email-jiri@resnulli.us>
 <52d57d84-6e0d-0ff3-5027-6dea06f4a683@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        Ido Schimmel <idosch@mellanox.com>,
        Elad Raz <eladr@mellanox.com>,
        Nogah Frankel <nogahf@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        "geert+renesas@glider.be" <geert+renesas@glider.be>,
        "stephen@networkplumber.org" <stephen@networkplumber.org>,
        "xiyou.wangcong@gmail.com" <xiyou.wangcong@gmail.com>,
        "linux@roeck-us.net" <linux@roeck-us.net>,
        "roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>,
        "john.fastabend@gmail.com" <john.fastabend@gmail.com>,
        "simon.horman@netronome.com" <simon.horman@netronome.com>,
        "mrv@mojatatu.com" <mrv@mojatatu.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>, Jiri Pirko <jiri@resnulli.us>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr30083.outbound.protection.outlook.com ([40.107.3.83]:37232
        "EHLO EUR03-AM5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750985AbdAVN23 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 22 Jan 2017 08:28:29 -0500
In-Reply-To: <52d57d84-6e0d-0ff3-5027-6dea06f4a683@mojatatu.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Jamal Hadi Salim [mailto:jhs@mojatatu.com]
>Sent: Sunday, January 22, 2017 3:17 PM
>To: Jiri Pirko <jiri@resnulli.us>; netdev@vger.kernel.org
>Cc: davem@davemloft.net; Yotam Gigi <yotamg@mellanox.com>; Ido Schimmel
><idosch@mellanox.com>; Elad Raz <eladr@mellanox.com>; Nogah Frankel
><nogahf@mellanox.com>; Or Gerlitz <ogerlitz@mellanox.com>;
>geert+renesas@glider.be; stephen@networkplumber.org;
>xiyou.wangcong@gmail.com; linux@roeck-us.net; roopa@cumulusnetworks.com;
>john.fastabend@gmail.com; simon.horman@netronome.com; mrv@mojatatu.com
>Subject: Re: [patch net-next 2/4] net/sched: Introduce sample tc action
>
>On 17-01-22 06:44 AM, Jiri Pirko wrote:
>
>> diff --git a/net/sched/act_sample.c b/net/sched/act_sample.c
>> new file mode 100644
>> index 0000000..24e20e4
>> --- /dev/null
>> +++ b/net/sched/act_sample.c
>> @@ -0,0 +1,274 @@
>> +/*
>> + * net/sched/act_sample.c - Packet samplig tc action
>
>typo: "Sampling"

It took me a while to see it. Will fix :)

>
>
>> +static int tcf_sample(struct sk_buff *skb, const struct tc_action *a,
>> +		      struct tcf_result *res)
>
>
>Can you rename this function because it is also the name of the data
>structure? It makes it easier to grep.
>I know we have this all over the place in other actions (and i hope
>those are cleaned up at some point).

OK, makes sense.

>
>otherwise:
>Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

Thanks!=20

>
>cheers,
>jamal
