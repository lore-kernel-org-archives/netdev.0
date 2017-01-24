From: Yotam Gigi <yotamg@mellanox.com>
Subject: RE: [patch net-next v2 2/4] net/sched: Introduce sample tc action
Date: Tue, 24 Jan 2017 08:39:37 +0000
Message-ID: <DB3PR05MB076447766A61C7CD63F5875CAC750@DB3PR05MB0764.eurprd05.prod.outlook.com>
References: <1485166031-4773-1-git-send-email-jiri@resnulli.us>
 <1485166031-4773-3-git-send-email-jiri@resnulli.us>
 <20170124083318.GB25022@penelope.horms.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
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
        "roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>,
        "john.fastabend@gmail.com" <john.fastabend@gmail.com>,
        "mrv@mojatatu.com" <mrv@mojatatu.com>
To: Simon Horman <simon.horman@netronome.com>,
        Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-he1eur01on0058.outbound.protection.outlook.com ([104.47.0.58]:19973
        "EHLO EUR01-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751037AbdAXIjx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 24 Jan 2017 03:39:53 -0500
In-Reply-To: <20170124083318.GB25022@penelope.horms.nl>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Simon Horman [mailto:simon.horman@netronome.com]
>Sent: Tuesday, January 24, 2017 10:33 AM
>To: Jiri Pirko <jiri@resnulli.us>
>Cc: netdev@vger.kernel.org; davem@davemloft.net; Yotam Gigi
><yotamg@mellanox.com>; Ido Schimmel <idosch@mellanox.com>; Elad Raz
><eladr@mellanox.com>; Nogah Frankel <nogahf@mellanox.com>; Or Gerlitz
><ogerlitz@mellanox.com>; jhs@mojatatu.com; geert+renesas@glider.be;
>stephen@networkplumber.org; xiyou.wangcong@gmail.com; linux@roeck-us.net;
>roopa@cumulusnetworks.com; john.fastabend@gmail.com; mrv@mojatatu.com
>Subject: Re: [patch net-next v2 2/4] net/sched: Introduce sample tc action
>
>On Mon, Jan 23, 2017 at 11:07:09AM +0100, Jiri Pirko wrote:
>> From: Yotam Gigi <yotamg@mellanox.com>
>>
>> This action allows the user to sample traffic matched by tc classifier.
>> The sampling consists of choosing packets randomly and sampling them usi=
ng
>> the psample module. The user can configure the psample group number, the
>> sampling rate and the packet's truncation (to save kernel-user traffic).
>>
>> Example:
>> To sample ingress traffic from interface eth1, one may use the commands:
>>
>> tc qdisc add dev eth1 handle ffff: ingress
>>
>> tc filter add dev eth1 parent ffff: \
>> 	   matchall action sample rate 12 group 4
>>
>> Where the first command adds an ingress qdisc and the second starts
>> sampling randomly with an average of one sampled packet per 12 packets o=
n
>> dev eth1 to psample group 4.
>>
>> Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>> Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>
>
>Reviewed-by: Simon Horman <simon.horman@netronome.com>
>
>Is the tc user-space (iproute2) code available yet?

Yes it is. I thought about sending it the moment the kernel patches gets=20
accepted.

Do you want it to send it directly to you?
