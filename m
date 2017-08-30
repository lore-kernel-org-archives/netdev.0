From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net 9/9] sch_tbf: fix two null pointer dereferences on
 init failure
Date: Wed, 30 Aug 2017 10:37:53 -0700
Message-ID: <CAM_iQpWn_q4CaOKhw7nxFR40V2JaVwr_5kx-ZUpdFxPa4hxKyA@mail.gmail.com>
References: <1504086545-7777-1-git-send-email-nikolay@cumulusnetworks.com> <1504086545-7777-10-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Pirko <jiri@resnulli.us>,
        Roopa Prabhu <roopa@cumulusnetworks.com>
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:36181 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752122AbdH3RiO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 13:38:14 -0400
Received: by mail-pf0-f174.google.com with SMTP id r187so473233pfr.3
        for <netdev@vger.kernel.org>; Wed, 30 Aug 2017 10:38:14 -0700 (PDT)
In-Reply-To: <1504086545-7777-10-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 30, 2017 at 2:49 AM, Nikolay Aleksandrov
<nikolay@cumulusnetworks.com> wrote:
> Reproduce:
> $ sysctl net.core.default_qdisc=tbf
> $ ip l set ethX up

I once upon a time had a patch to disallow those qdisc's
to be default. Probably I should resend it.
