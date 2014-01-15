From: Cong Wang <cwang@twopensource.com>
Subject: Re: [Patch net-next] net_sched: act: remove headers in include/net/tc_act/
Date: Tue, 14 Jan 2014 17:17:40 -0800
Message-ID: <CAHA+R7N1wpiYq9vcqEFLL=CNQDZ+4fEHbirpMazWVJg0=uBs9Q@mail.gmail.com>
References: <1389747699-32508-1-git-send-email-xiyou.wangcong@gmail.com>
	<1389748310.31367.298.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:56758 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750918AbaAOBRl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 20:17:41 -0500
Received: by mail-la0-f54.google.com with SMTP id y1so933965lam.27
        for <netdev@vger.kernel.org>; Tue, 14 Jan 2014 17:17:40 -0800 (PST)
In-Reply-To: <1389748310.31367.298.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 14, 2014 at 5:11 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2014-01-14 at 17:01 -0800, Cong Wang wrote:
>> These headers are not necessary because those definitions in them
>> are action specific and are not shared for others. Just move them
>> into the C files.
>>
>> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
>> Cc: David S. Miller <davem@davemloft.net>
>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>> ---
>
> I find this change very dubious.

grep told me it isn't:

$ git grep 'include.*tc_act/'
net/sched/act_csum.c:#include <linux/tc_act/tc_csum.h>
net/sched/act_gact.c:#include <linux/tc_act/tc_gact.h>
net/sched/act_ipt.c:#include <linux/tc_act/tc_ipt.h>
net/sched/act_mirred.c:#include <linux/tc_act/tc_mirred.h>
net/sched/act_nat.c:#include <linux/tc_act/tc_nat.h>
net/sched/act_pedit.c:#include <linux/tc_act/tc_pedit.h>
net/sched/act_simple.c:#include <linux/tc_act/tc_defact.h>
net/sched/act_skbedit.c:#include <linux/tc_act/tc_skbedit.h>

(those are uapi headers, which I don't touch.)
