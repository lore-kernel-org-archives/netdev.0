From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net v4 6/7] net_sched: unify the init logic for act_police
Date: Sun, 14 Aug 2016 07:04:35 -0400
Message-ID: <9df96b68-67dd-3631-d8f3-abb57d2a08ae@mojatatu.com>
References: <1471152902-12444-1-git-send-email-xiyou.wangcong@gmail.com>
 <1471152902-12444-7-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:33079 "EHLO
	mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933248AbcHNLSl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Aug 2016 07:18:41 -0400
Received: by mail-qk0-f193.google.com with SMTP id x189so2365624qkd.0
        for <netdev@vger.kernel.org>; Sun, 14 Aug 2016 04:18:41 -0700 (PDT)
In-Reply-To: <1471152902-12444-7-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-08-14 01:35 AM, Cong Wang wrote:
> Jamal reported a crash when we create a police action
> with a specific index, this is because the init logic
> is not correct, we should always create one for this
> case. Just unify the logic with other tc actions.
>
> Fixes: a03e6fe56971 ("act_police: fix a crash during removal")
> Reported-by: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
