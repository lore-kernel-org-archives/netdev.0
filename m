From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next 1/1] net sched: stylistic cleanups
Date: Sun, 18 Sep 2016 16:38:56 -0700
Message-ID: <CAM_iQpWnQ6T3Om38HMQzvxb6QpDYv52ATnApxMn03htcA8AZTA@mail.gmail.com>
References: <1474202733-14740-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f48.google.com ([209.85.214.48]:35364 "EHLO
        mail-it0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755419AbcIRXjR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Sep 2016 19:39:17 -0400
Received: by mail-it0-f48.google.com with SMTP id r192so55614729ita.0
        for <netdev@vger.kernel.org>; Sun, 18 Sep 2016 16:39:16 -0700 (PDT)
In-Reply-To: <1474202733-14740-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 18, 2016 at 5:45 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>         rtnl_register(PF_UNSPEC, RTM_NEWQDISC, tc_modify_qdisc, NULL, NULL);
>         rtnl_register(PF_UNSPEC, RTM_DELQDISC, tc_get_qdisc, NULL, NULL);
> -       rtnl_register(PF_UNSPEC, RTM_GETQDISC, tc_get_qdisc, tc_dump_qdisc, NULL);
> +       rtnl_register(PF_UNSPEC, RTM_GETQDISC, tc_get_qdisc, tc_dump_qdisc,
> +                     NULL);
>         rtnl_register(PF_UNSPEC, RTM_NEWTCLASS, tc_ctl_tclass, NULL, NULL);
>         rtnl_register(PF_UNSPEC, RTM_DELTCLASS, tc_ctl_tclass, NULL, NULL);
> -       rtnl_register(PF_UNSPEC, RTM_GETTCLASS, tc_ctl_tclass, tc_dump_tclass, NULL);
> +       rtnl_register(PF_UNSPEC, RTM_GETTCLASS, tc_ctl_tclass, tc_dump_tclass,
> +                     NULL);

Keeping them in the same line is more readable, IMHO.
