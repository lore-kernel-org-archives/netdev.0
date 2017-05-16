From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [patch net-next v3 01/10] net: sched: move tc_classify function
 to cls_api.c
Date: Tue, 16 May 2017 13:25:35 -0700
Message-ID: <CAM_iQpVqRTcK0H3wSiUEOXSk+pWtriSLFy7jtN6d77wrTjqe3Q@mail.gmail.com>
References: <20170516172802.1317-1-jiri@resnulli.us> <20170516172802.1317-2-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        David Ahern <dsa@cumulusnetworks.com>,
        Eric Dumazet <edumazet@google.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Simon Horman <simon.horman@netronome.com>, mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34242 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750876AbdEPUZ5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 16:25:57 -0400
Received: by mail-wm0-f68.google.com with SMTP id d127so40520577wmf.1
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 13:25:56 -0700 (PDT)
In-Reply-To: <20170516172802.1317-2-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 16, 2017 at 10:27 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> From: Jiri Pirko <jiri@mellanox.com>
>
> Move tc_classify function to cls_api.c where it belongs, rename it to
> fit the namespace.
>

It is not a pure move, you silently remove the CONFIG_NET_CLS_ACT
macros in tc_classify(). Probably not buggy, just redundancy when
actions are not compiled.
