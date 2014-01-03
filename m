From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next 0/3] net_sched: act: Various fixes
Date: Fri, 03 Jan 2014 07:24:54 -0500
Message-ID: <52C6AC16.4000103@mojatatu.com>
References: <1387803733-19709-1-git-send-email-jhs@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
	eric.dumazet@gmail.com, Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:40647 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750837AbaACMY5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jan 2014 07:24:57 -0500
Received: by mail-ie0-f180.google.com with SMTP id tp5so15213610ieb.25
        for <netdev@vger.kernel.org>; Fri, 03 Jan 2014 04:24:56 -0800 (PST)
In-Reply-To: <1387803733-19709-1-git-send-email-jhs@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Patches 2 + 3 are missing (from both tree and patchwork).

cheers,
jamal

On 12/23/13 08:02, Jamal Hadi Salim wrote:
> The first and last are bug fixes. The second one is a code improvement
>
> Jamal Hadi Salim (3):
>    Dont increment refcnt on replace
>    Remove unnecessary checks for act->ops
>    action flushing missaccounting
>
>   net/sched/act_api.c     |   51 +++++++++++++++++------------------------------
>   net/sched/act_csum.c    |   10 +++++-----
>   net/sched/act_gact.c    |    7 ++++---
>   net/sched/act_ipt.c     |    8 +++++---
>   net/sched/act_nat.c     |   10 +++++-----
>   net/sched/act_pedit.c   |    8 +++++---
>   net/sched/act_police.c  |    4 +++-
>   net/sched/act_simple.c  |    9 ++++++---
>   net/sched/act_skbedit.c |    7 ++++---
>   net/sched/cls_api.c     |    2 +-
>   10 files changed, 56 insertions(+), 60 deletions(-)
>
