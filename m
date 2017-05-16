From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v3 01/10] net: sched: move tc_classify function
 to cls_api.c
Date: Tue, 16 May 2017 23:00:38 +0200
Message-ID: <20170516210038.GR1939@nanopsycho.orion>
References: <20170516172802.1317-1-jiri@resnulli.us>
 <20170516172802.1317-2-jiri@resnulli.us>
 <CAM_iQpVqRTcK0H3wSiUEOXSk+pWtriSLFy7jtN6d77wrTjqe3Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        David Ahern <dsa@cumulusnetworks.com>,
        Eric Dumazet <edumazet@google.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Simon Horman <simon.horman@netronome.com>, mlxsw@mellanox.com
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35612 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750799AbdEPVAl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 17:00:41 -0400
Received: by mail-wm0-f66.google.com with SMTP id v4so40831515wmb.2
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 14:00:40 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAM_iQpVqRTcK0H3wSiUEOXSk+pWtriSLFy7jtN6d77wrTjqe3Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, May 16, 2017 at 10:25:35PM CEST, xiyou.wangcong@gmail.com wrote:
>On Tue, May 16, 2017 at 10:27 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>> From: Jiri Pirko <jiri@mellanox.com>
>>
>> Move tc_classify function to cls_api.c where it belongs, rename it to
>> fit the namespace.
>>
>
>It is not a pure move, you silently remove the CONFIG_NET_CLS_ACT
>macros in tc_classify(). Probably not buggy, just redundancy when
>actions are not compiled.

Plese see include/net/pkt_cls.h in this patch.

If CONFIG_NET_CLS_ACT is not defined, there is a stub there.
