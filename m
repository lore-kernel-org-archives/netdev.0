From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next v3 05/10] net: sched: move TC_H_MAJ macro call
 into tcf_auto_prio
Date: Wed, 17 May 2017 08:47:47 -0400
Message-ID: <e4614c93-16c9-427c-838d-4e752276cbe0@mojatatu.com>
References: <20170516172802.1317-1-jiri@resnulli.us>
 <20170516172802.1317-6-jiri@resnulli.us>
 <CAM_iQpXUY03tfi1RHLx0EnT5ZP1xPNdo4xGmUUiSKvRtSg44vw@mail.gmail.com>
 <20170516210346.GS1939@nanopsycho.orion>
 <CAM_iQpUcoK04Xim8PbHg3GVykhioCA1MrBd3Ddd7HERaVYELQg@mail.gmail.com>
 <20170517054752.GB1832@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        David Ahern <dsa@cumulusnetworks.com>,
        Eric Dumazet <edumazet@google.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Simon Horman <simon.horman@netronome.com>, mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>, Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f172.google.com ([209.85.223.172]:34442 "EHLO
        mail-io0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751704AbdEQMru (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 08:47:50 -0400
Received: by mail-io0-f172.google.com with SMTP id k91so8311425ioi.1
        for <netdev@vger.kernel.org>; Wed, 17 May 2017 05:47:50 -0700 (PDT)
In-Reply-To: <20170517054752.GB1832@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-05-17 01:47 AM, Jiri Pirko wrote:
> Wed, May 17, 2017 at 12:38:08AM CEST, xiyou.wangcong@gmail.com wrote:

[..]
>>
>> tcf_auto_major_prio()?
>
> That makes no sense. prio is passed from user in upper 2 bytes (god
> knows why but that is how it is).

I am not sure it is any god's decision ;-> Unless you think the creator
of this semantic is a god which in some circles is blasphemy ;->

16 bits for prio: 16 bits for proto - what is the problem?

cheers,
jamal
