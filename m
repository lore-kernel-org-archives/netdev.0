From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net-next] net_sched: check NULL on error path in
 route4_change()
Date: Thu, 22 Sep 2016 19:26:43 -0400
Message-ID: <061484e0-e0a4-2103-8854-f697cef244d0@mojatatu.com>
References: <1474239140-6738-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:36169 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751667AbcIVX0q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 19:26:46 -0400
Received: by mail-it0-f65.google.com with SMTP id n143so3420ita.3
        for <netdev@vger.kernel.org>; Thu, 22 Sep 2016 16:26:46 -0700 (PDT)
In-Reply-To: <1474239140-6738-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-09-18 06:52 PM, Cong Wang wrote:
> On error path in route4_change(), 'f' could be NULL,
> so we should check NULL before calling tcf_exts_destroy().
>
> Fixes: b9a24bb76bf6 ("net_sched: properly handle failure case of tcf_exts_init()")
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
