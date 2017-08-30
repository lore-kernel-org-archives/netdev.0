From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net 9/9] sch_tbf: fix two null pointer dereferences on
 init failure
Date: Thu, 31 Aug 2017 00:39:04 +0300
Message-ID: <65893557-1461-9ab6-9ca6-e52e67b84683@cumulusnetworks.com>
References: <1504086545-7777-1-git-send-email-nikolay@cumulusnetworks.com>
 <1504086545-7777-10-git-send-email-nikolay@cumulusnetworks.com>
 <CAM_iQpWn_q4CaOKhw7nxFR40V2JaVwr_5kx-ZUpdFxPa4hxKyA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Pirko <jiri@resnulli.us>,
        Roopa Prabhu <roopa@cumulusnetworks.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:34496 "EHLO
        mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750761AbdH3VjH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 17:39:07 -0400
Received: by mail-wm0-f49.google.com with SMTP id 137so4418734wmj.1
        for <netdev@vger.kernel.org>; Wed, 30 Aug 2017 14:39:07 -0700 (PDT)
In-Reply-To: <CAM_iQpWn_q4CaOKhw7nxFR40V2JaVwr_5kx-ZUpdFxPa4hxKyA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 30/08/17 20:37, Cong Wang wrote:
> On Wed, Aug 30, 2017 at 2:49 AM, Nikolay Aleksandrov
> <nikolay@cumulusnetworks.com> wrote:
>> Reproduce:
>> $ sysctl net.core.default_qdisc=tbf
>> $ ip l set ethX up
> 
> I once upon a time had a patch to disallow those qdisc's
> to be default. Probably I should resend it.
> 

That sounds good. A lot of them can't be default anyway, they need
some options to be set, so it's definitely worth looking into.
