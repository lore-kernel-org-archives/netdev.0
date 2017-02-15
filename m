From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next V2 1/6] net/sched: cls_matchall: Dump skip flags
Date: Wed, 15 Feb 2017 10:20:54 +0200
Message-ID: <CAJ3xEMgX0_i+qb81QTHuxpyFdeH=_pcGAqtc3uTWYg3njvjPEA@mail.gmail.com>
References: <1487082640-24813-1-git-send-email-ogerlitz@mellanox.com>
 <1487082640-24813-2-git-send-email-ogerlitz@mellanox.com> <20170214112834.3a5d9929@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        John Fastabend <john.r.fastabend@intel.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Roi Dayan <roid@mellanox.com>,
        Paul Blakey <paulb@mellanox.com>,
        Linux Netdev List <netdev@vger.kernel.org>
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:34112 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750931AbdBOIU4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2017 03:20:56 -0500
Received: by mail-oi0-f65.google.com with SMTP id w144so2401365oiw.1
        for <netdev@vger.kernel.org>; Wed, 15 Feb 2017 00:20:55 -0800 (PST)
In-Reply-To: <20170214112834.3a5d9929@cakuba.netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 14, 2017 at 9:28 PM, Jakub Kicinski <kubakici@wp.pl> wrote:
> On Tue, 14 Feb 2017 16:30:35 +0200, Or Gerlitz wrote:
>> The skip flags are not dumped to user-space, do that.
>>
>> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
>> Acked-by: Jiri Pirko <jiri@mellanox.com>
>> Acked-by: Yotam Gigi <yotamg@mellanox.com>
>> ---
>>  net/sched/cls_matchall.c | 2 ++
>>  1 file changed, 2 insertions(+)
>>
>> diff --git a/net/sched/cls_matchall.c b/net/sched/cls_matchall.c
>> index f2141cb..ce2f7d4 100644
>> --- a/net/sched/cls_matchall.c
>> +++ b/net/sched/cls_matchall.c
>> @@ -244,6 +244,8 @@ static int mall_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
>>           nla_put_u32(skb, TCA_MATCHALL_CLASSID, head->res.classid))
>>               goto nla_put_failure;
>>
>> +     nla_put_u32(skb, TCA_MATCHALL_FLAGS, head->flags);
>> +
>
> Shouldn't the return status from nla_put_u32() be checked?

Yeah, amazing how the developer (me) and three internal reviewers
missed that :(, thanks!

Or.
