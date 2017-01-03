From: Yotam Gigi <yotamg@mellanox.com>
Subject: RE: [PATCH net-next] net/sched: cls_matchall: Fix error path
Date: Tue, 3 Jan 2017 16:13:46 +0000
Message-ID: <DB3PR05MB0764D7198D5FC6D534A90B89AC6E0@DB3PR05MB0764.eurprd05.prod.outlook.com>
References: <1483458422-13607-1-git-send-email-yotamg@mellanox.com>
 <20170103.110807.1415814934069793893.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "jhs@mojatatu.com" <jhs@mojatatu.com>,
        Elad Raz <eladr@mellanox.com>,
        "Jiri Pirko" <jiri@mellanox.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr20059.outbound.protection.outlook.com ([40.107.2.59]:20194
        "EHLO EUR02-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1759555AbdACQOw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Jan 2017 11:14:52 -0500
In-Reply-To: <20170103.110807.1415814934069793893.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: David Miller [mailto:davem@davemloft.net]
>Sent: Tuesday, January 03, 2017 6:08 PM
>To: Yotam Gigi <yotamg@mellanox.com>
>Cc: jhs@mojatatu.com; Elad Raz <eladr@mellanox.com>; Jiri Pirko
><jiri@mellanox.com>; netdev@vger.kernel.org
>Subject: Re: [PATCH net-next] net/sched: cls_matchall: Fix error path
>
>From: Yotam Gigi <yotamg@mellanox.com>
>Date: Tue,  3 Jan 2017 17:47:02 +0200
>
>> Fix several error paths in matchall:
>>  - Release reference to actions in case the hardware fails offloading
>>    (relevant to skip_sw only)
>>  - Fix error path in case tcf_exts initialization fails
>>
>> Fixes: bf3994d2ed31 ("net/sched: introduce Match-all classifier")
>> Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
>
>Nothing is checking the tcf_exts_init() return value for errors either,
>and I think you should fix this alongside these release problems at the
>same time.

Ok. Will send v2 soon.

Thanks!

>
>Thanks.
