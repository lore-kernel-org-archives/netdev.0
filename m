From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [patch net-next RFC] net: sched: cls_api: make reclassify return
 all the way back to the original tp
Date: Mon, 22 May 2017 16:57:47 -0700
Message-ID: <CAM_iQpUUfrCvaLUeEOyzCYg9_9sZ3URZeVaP13R7OTX9tLOQuQ@mail.gmail.com>
References: <20170522150942.1703-1-jiri@resnulli.us>
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
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35651 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758818AbdEVX6I (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 19:58:08 -0400
Received: by mail-wm0-f68.google.com with SMTP id g15so16402955wmc.2
        for <netdev@vger.kernel.org>; Mon, 22 May 2017 16:58:08 -0700 (PDT)
In-Reply-To: <20170522150942.1703-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 22, 2017 at 8:09 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> From: Jiri Pirko <jiri@mellanox.com>
>
> With the introduction of chain goto action, the reclassification would
> cause the re-iteration of the actual chain. But it perhaps makes more
> sense to restart the whole thing. Thoughts?

I think reclassification is meant to restart the whole logic rather
than just one chain. So your patch makes sense to me, but not
sure if there is any corner case I miss.
