From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net v4 5/7] net_sched: convert tcf_exts from list to
 pointer array
Date: Sun, 14 Aug 2016 07:04:00 -0400
Message-ID: <63d6a947-a367-88bd-4988-f59b51bcda48@mojatatu.com>
References: <1471152902-12444-1-git-send-email-xiyou.wangcong@gmail.com>
 <1471152902-12444-6-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f182.google.com ([209.85.216.182]:34038 "EHLO
	mail-qt0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964779AbcHNLEC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Aug 2016 07:04:02 -0400
Received: by mail-qt0-f182.google.com with SMTP id u25so11481346qtb.1
        for <netdev@vger.kernel.org>; Sun, 14 Aug 2016 04:04:01 -0700 (PDT)
In-Reply-To: <1471152902-12444-6-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-08-14 01:35 AM, Cong Wang wrote:
> As pointed out by Jamal, an action could be shared by
> multiple filters, so we can't use list to chain them
> any more after we get rid of the original tc_action.
> Instead, we could just save pointers to these actions
> in tcf_exts, since they are refcount'ed, so convert
> the list to an array of pointers.
>
> The "ugly" part is the action API still accepts list
> as a parameter, I just introduce a helper function to
> convert the array of pointers to a list, instead of
> relying on the C99 feature to iterate the array.
>
> Fixes: a85a970af265 ("net_sched: move tc_action into tcf_common")
> Reported-by: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>


cheers,
jamal
