From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next RFC] net: sched: cls_api: make reclassify return
 all the way back to the original tp
Date: Tue, 23 May 2017 07:15:02 +0200
Message-ID: <20170523051502.GA1829@nanopsycho>
References: <20170522150942.1703-1-jiri@resnulli.us>
 <CAM_iQpUUfrCvaLUeEOyzCYg9_9sZ3URZeVaP13R7OTX9tLOQuQ@mail.gmail.com>
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
Received: from mail-wr0-f195.google.com ([209.85.128.195]:36774 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1761117AbdEWFPF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 01:15:05 -0400
Received: by mail-wr0-f195.google.com with SMTP id v42so8849542wrc.3
        for <netdev@vger.kernel.org>; Mon, 22 May 2017 22:15:04 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAM_iQpUUfrCvaLUeEOyzCYg9_9sZ3URZeVaP13R7OTX9tLOQuQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, May 23, 2017 at 01:57:47AM CEST, xiyou.wangcong@gmail.com wrote:
>On Mon, May 22, 2017 at 8:09 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>> From: Jiri Pirko <jiri@mellanox.com>
>>
>> With the introduction of chain goto action, the reclassification would
>> cause the re-iteration of the actual chain. But it perhaps makes more
>> sense to restart the whole thing. Thoughts?
>
>I think reclassification is meant to restart the whole logic rather
>than just one chain. So your patch makes sense to me, but not
>sure if there is any corner case I miss.

Agreed. Will send v1. Thanks
