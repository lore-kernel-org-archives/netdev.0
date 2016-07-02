From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH v2 net-next 1/1] net sched actions: mirred add support for
 setting Dst MAC address
Date: Sat, 2 Jul 2016 17:16:50 +0200
Message-ID: <5777DAE2.4000702@cumulusnetworks.com>
References: <1467470065-17613-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net,
	xiyou.wangcong@gmail.com
To: Jamal Hadi Salim <jhs@mojatatu.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:35148 "EHLO
	mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752138AbcGBPQy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jul 2016 11:16:54 -0400
Received: by mail-wm0-f54.google.com with SMTP id v199so57290618wmv.0
        for <netdev@vger.kernel.org>; Sat, 02 Jul 2016 08:16:53 -0700 (PDT)
In-Reply-To: <1467470065-17613-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/07/16 16:34, Jamal Hadi Salim wrote:
> From: Jamal Hadi Salim <jhs@mojatatu.com>
> 
> Often redirecting or mirroring requires that we set the dstMAC address
> of the target device. While it is possible to pipe to a pedit action,
> this patch obsoletes the need for that. This is a justified feature because
> the dst MAC addresses rewrite is such a common use case.
> 
> Sample usage:
> sudo $TC filter add dev $ETH parent 1: protocol ip prio 10 \
> u32 match ip protocol 1 0xff flowid 1:2 \
> action mirred egress redirect dev $SPANPORT dst 02:15:15:15:15:15
> 
> This will match all icmp packets going out on dev $ETH and
> redirect them to dev $SPANPORT while setting their dst MAC address
> to 02:15:15:15:15:15
> 
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
> ---
>  include/net/tc_act/tc_mirred.h        |  4 +++-
>  include/uapi/linux/tc_act/tc_mirred.h |  7 ++++---
>  net/sched/act_mirred.c                | 24 +++++++++++++++++++++++-
>  3 files changed, 30 insertions(+), 5 deletions(-)
> 

LGTM, thanks!

Reviewed-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
