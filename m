From: Shmulik Ladkani <shmulik.ladkani@ravellosystems.com>
Subject: Re: [PATCH net-next 4/4] net/sched: act_mirred: Implement ingress
 actions
Date: Tue, 27 Sep 2016 11:07:11 +0300
Message-ID: <20160927110711.12555f4e@pixies>
References: <1474550512-7552-1-git-send-email-shmulik.ladkani@gmail.com>
        <1474550512-7552-5-git-send-email-shmulik.ladkani@gmail.com>
        <20160927.015606.437705429903770747.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, xiyou.wangcong@gmail.com, edumazet@google.com,
        netdev@vger.kernel.org, shmulik.ladkani@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f181.google.com ([209.85.220.181]:35201 "EHLO
        mail-qk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754133AbcI0IH2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 04:07:28 -0400
Received: by mail-qk0-f181.google.com with SMTP id t7so8189393qkh.2
        for <netdev@vger.kernel.org>; Tue, 27 Sep 2016 01:07:28 -0700 (PDT)
In-Reply-To: <20160927.015606.437705429903770747.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Tue, 27 Sep 2016 01:56:06 -0400 (EDT), davem@davemloft.net wrote:
> The discussion on this patch has ventured off into what to do about
> recursion.
> 
> But it unclear to me where this specific patch, and this series,
> stands right now.  Someone please clear this up for me.

Status:
 - Series adds "ingress redirect/mirror" support
 - Positive feedback for the feature
 - So far no comments regarding code itself
 - Questions raised regarding "recursion handling"
   Expressed that existing mirred code (i.e egress redirect) is *already*
   loop-unsafe (and also, some non-tc netdev constructs, as exampled by
   others).
   Discussion then wandered to "recursion handling".

Regards,
Shmulik	
