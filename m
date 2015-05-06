From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net] net_sched: fix a use-after-free in tc_ctl_tfilter()
Date: Wed, 06 May 2015 17:24:53 -0400
Message-ID: <554A86A5.2030804@mojatatu.com>
References: <1430864522-15691-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:32854 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751183AbbEFVY4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 17:24:56 -0400
Received: by igbpi8 with SMTP id pi8so106546905igb.0
        for <netdev@vger.kernel.org>; Wed, 06 May 2015 14:24:56 -0700 (PDT)
In-Reply-To: <1430864522-15691-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/05/15 18:22, Cong Wang wrote:
> When tcf_destroy() returns true, tp could be already destroyed,
> we should not use tp->next after that.
>
> For long term, we probably should move tp list to list_head.
>
> Fixes: 1e052be69d04 ("net_sched: destroy proto tp when all filters are gone")
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>


cheers,
jamal
