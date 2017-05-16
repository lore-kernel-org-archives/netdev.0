From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [patch net-next v3 05/10] net: sched: move TC_H_MAJ macro call
 into tcf_auto_prio
Date: Tue, 16 May 2017 14:01:52 -0700
Message-ID: <CAM_iQpXUY03tfi1RHLx0EnT5ZP1xPNdo4xGmUUiSKvRtSg44vw@mail.gmail.com>
References: <20170516172802.1317-1-jiri@resnulli.us> <20170516172802.1317-6-jiri@resnulli.us>
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
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33695 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751953AbdEPVCO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 17:02:14 -0400
Received: by mail-wm0-f67.google.com with SMTP id y10so40863611wmh.0
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 14:02:14 -0700 (PDT)
In-Reply-To: <20170516172802.1317-6-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 16, 2017 at 10:27 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> From: Jiri Pirko <jiri@mellanox.com>
>
> Call the helper from the function rather than to always adjust the
> return value of the function.

And rename the function name to reflect this change?
