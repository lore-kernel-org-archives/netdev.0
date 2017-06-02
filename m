From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch iproute2 v2 repost 3/3] tc/actions: introduce support for
 goto chain action
Date: Fri, 2 Jun 2017 10:15:12 +0200
Message-ID: <20170602081512.GB2015@nanopsycho.orion>
References: <20170516172802.1317-1-jiri@resnulli.us>
 <20170516172937.1391-3-jiri@resnulli.us>
 <20170531142702.6d0ca6fa@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com,
        xiyou.wangcong@gmail.com, dsa@cumulusnetworks.com,
        edumazet@google.com, stephen@networkplumber.org,
        daniel@iogearbox.net, alexander.h.duyck@intel.com,
        simon.horman@netronome.com, mlxsw@mellanox.com
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34674 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750826AbdFBIPP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2017 04:15:15 -0400
Received: by mail-wm0-f68.google.com with SMTP id d127so17022608wmf.1
        for <netdev@vger.kernel.org>; Fri, 02 Jun 2017 01:15:14 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170531142702.6d0ca6fa@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, May 31, 2017 at 02:27:02PM CEST, jbenc@redhat.com wrote:
>On Tue, 16 May 2017 19:29:37 +0200, Jiri Pirko wrote:
>> From: Jiri Pirko <jiri@mellanox.com>
>> 
>> Allow user to set control action "goto" with filter chain index as
>> a parameter.
>> 
>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>> ---
>>  include/linux/pkt_cls.h | 16 +++++++++++++++-
>>  man/man8/tc-ife.8       |  2 +-
>>  man/man8/tc-pedit.8     |  2 +-
>>  man/man8/tc-police.8    |  2 +-
>>  man/man8/tc-vlan.8      |  2 +-
>
>Jiri, this *seriously* needs a proper documentation. I consider myself
>to be well above average in understanding tc filters and actions, and as
>you know I participated at least passively in some chats about the
>chains. Yet I'm still very lost in semantics of chains. I cannot
>imagine how an average user would be able to use this.
>
>Some questions about the semantics:
>
>- What chain(s) are processed by default? If I don't use goto_chain but
>  have multiple chains, will only chain 0 be processed, or more? In
>  what order, what are the rules? If I don't have a chain 0, what would
>  happen?

0 only. I exepcter it makes sense. But you are right, I will put it to
man.


>
>- What is the relation between priorities and chains? I expected that
>  chains are under the same priority but that's not the case in your
>  example. For a user, it's very unclear why there are priorities and
>  chains. They appear to do the same thing, why can't I just jump
>  between priorities?

Basically, what we had previously was single chain (0) only. Now we have
multichain, each chain is completely independent list of tps, each tp
having its prio.



I will also add this to man.


>
>Please, in addition to explaining here on the list, add detailed
>explanation to the man pages.
>
>Thanks,
>
> Jiri
