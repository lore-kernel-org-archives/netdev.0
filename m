From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v3 05/10] net: sched: move TC_H_MAJ macro call
 into tcf_auto_prio
Date: Wed, 17 May 2017 07:47:52 +0200
Message-ID: <20170517054752.GB1832@nanopsycho>
References: <20170516172802.1317-1-jiri@resnulli.us>
 <20170516172802.1317-6-jiri@resnulli.us>
 <CAM_iQpXUY03tfi1RHLx0EnT5ZP1xPNdo4xGmUUiSKvRtSg44vw@mail.gmail.com>
 <20170516210346.GS1939@nanopsycho.orion>
 <CAM_iQpUcoK04Xim8PbHg3GVykhioCA1MrBd3Ddd7HERaVYELQg@mail.gmail.com>
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
Received: from mail-wr0-f196.google.com ([209.85.128.196]:34303 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752293AbdEQFrz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 01:47:55 -0400
Received: by mail-wr0-f196.google.com with SMTP id 6so215883wrb.1
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 22:47:54 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAM_iQpUcoK04Xim8PbHg3GVykhioCA1MrBd3Ddd7HERaVYELQg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, May 17, 2017 at 12:38:08AM CEST, xiyou.wangcong@gmail.com wrote:
>On Tue, May 16, 2017 at 2:03 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>> Tue, May 16, 2017 at 11:01:52PM CEST, xiyou.wangcong@gmail.com wrote:
>>>On Tue, May 16, 2017 at 10:27 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>>>> From: Jiri Pirko <jiri@mellanox.com>
>>>>
>>>> Call the helper from the function rather than to always adjust the
>>>> return value of the function.
>>>
>>>And rename the function name to reflect this change?
>>
>> ? What do you suggest?
>
>tcf_auto_major_prio()?

That makes no sense. prio is passed from user in upper 2 bytes (god
knows why but that is how it is). The helper returns prio, that's it.
Nothing major about it...
