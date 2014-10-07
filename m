From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net] net_sched: copy exts->type in tcf_exts_change()
Date: Tue, 07 Oct 2014 07:33:58 -0400
Message-ID: <5433CFA6.8060901@mojatatu.com>
References: <1412641314-17335-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:37233 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751334AbaJGLeD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 07:34:03 -0400
Received: by mail-ie0-f176.google.com with SMTP id rp18so5111780iec.21
        for <netdev@vger.kernel.org>; Tue, 07 Oct 2014 04:34:01 -0700 (PDT)
In-Reply-To: <1412641314-17335-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/06/14 20:21, Cong Wang wrote:
> We need to copy exts->type when committing the change, otherwise
> it would be always 0. This is a quick fix for -net and -stable,
> for net-next tcf_exts will be removed.
>
> Fixes: commit 33be627159913b094bb578e83 ("net_sched: act: use standard struct list_head")
> Reported-by: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: John Fastabend <john.fastabend@gmail.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>


cheers,
jamal
