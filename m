From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Fw: New Defects reported by Coverity Scan for Linux
Date: Mon, 24 Apr 2017 17:09:38 -0700
Message-ID: <CAM_iQpUTxNdp-uC0pGkvW0uceOpouAQ1abrU-u4wvR9ftqXN7w@mail.gmail.com>
References: <20170424164127.5a2145e8@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jamal Hadi Salim <hadi@mojatatu.com>,
        Jiri Pirko <jiri@resnulli.us>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:36862 "EHLO
        mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S969986AbdDYAJ7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 20:09:59 -0400
Received: by mail-wm0-f42.google.com with SMTP id u65so9602327wmu.1
        for <netdev@vger.kernel.org>; Mon, 24 Apr 2017 17:09:59 -0700 (PDT)
In-Reply-To: <20170424164127.5a2145e8@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 24, 2017 at 4:41 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> This looks like a false positive
> ________________________________________________________________________________________________________
> *** CID 1405487:  Resource leaks  (RESOURCE_LEAK)
> /net/sched/act_api.c: 635 in tcf_action_init_1()
> 629              * if it exists and is only bound to in a_o->init() then
> 630              * ACT_P_CREATED is not returned (a zero is).
> 631              */
> 632             if (err != ACT_P_CREATED)
> 633                     module_put(a_o->owner);
> 634
>>>>     CID 1405487:  Resource leaks  (RESOURCE_LEAK)
>>>>     Variable "cookie" going out of scope leaks the storage it points to.
> 635             return a;

I don't see how we could leak it either.
