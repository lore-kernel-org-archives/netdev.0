From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v3 05/10] net: sched: move TC_H_MAJ macro call
 into tcf_auto_prio
Date: Wed, 17 May 2017 14:53:47 +0200
Message-ID: <20170517125347.GC9557@nanopsycho>
References: <20170516172802.1317-1-jiri@resnulli.us>
 <20170516172802.1317-6-jiri@resnulli.us>
 <CAM_iQpXUY03tfi1RHLx0EnT5ZP1xPNdo4xGmUUiSKvRtSg44vw@mail.gmail.com>
 <20170516210346.GS1939@nanopsycho.orion>
 <CAM_iQpUcoK04Xim8PbHg3GVykhioCA1MrBd3Ddd7HERaVYELQg@mail.gmail.com>
 <20170517054752.GB1832@nanopsycho>
 <e4614c93-16c9-427c-838d-4e752276cbe0@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        David Ahern <dsa@cumulusnetworks.com>,
        Eric Dumazet <edumazet@google.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Simon Horman <simon.horman@netronome.com>, mlxsw@mellanox.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36338 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754463AbdEQMxt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 08:53:49 -0400
Received: by mail-wm0-f65.google.com with SMTP id k15so2018251wmh.3
        for <netdev@vger.kernel.org>; Wed, 17 May 2017 05:53:49 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <e4614c93-16c9-427c-838d-4e752276cbe0@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, May 17, 2017 at 02:47:47PM CEST, jhs@mojatatu.com wrote:
>On 17-05-17 01:47 AM, Jiri Pirko wrote:
>> Wed, May 17, 2017 at 12:38:08AM CEST, xiyou.wangcong@gmail.com wrote:
>
>[..]
>> > 
>> > tcf_auto_major_prio()?
>> 
>> That makes no sense. prio is passed from user in upper 2 bytes (god
>> knows why but that is how it is).
>
>I am not sure it is any god's decision ;-> Unless you think the creator
>of this semantic is a god which in some circles is blasphemy ;->
>
>16 bits for prio: 16 bits for proto - what is the problem?

Should have been a struct, at least. But as you know, I always prefer
a Netlink attr :)
