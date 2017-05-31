From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [patch iproute2 v2 repost 3/3] tc/actions: introduce support
 for goto chain action
Date: Wed, 31 May 2017 14:27:02 +0200
Message-ID: <20170531142702.6d0ca6fa@griffin>
References: <20170516172802.1317-1-jiri@resnulli.us>
        <20170516172937.1391-3-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com,
        xiyou.wangcong@gmail.com, dsa@cumulusnetworks.com,
        edumazet@google.com, stephen@networkplumber.org,
        daniel@iogearbox.net, alexander.h.duyck@intel.com,
        simon.horman@netronome.com, mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46344 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751000AbdEaM1I (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 31 May 2017 08:27:08 -0400
In-Reply-To: <20170516172937.1391-3-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 16 May 2017 19:29:37 +0200, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>
> 
> Allow user to set control action "goto" with filter chain index as
> a parameter.
> 
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  include/linux/pkt_cls.h | 16 +++++++++++++++-
>  man/man8/tc-ife.8       |  2 +-
>  man/man8/tc-pedit.8     |  2 +-
>  man/man8/tc-police.8    |  2 +-
>  man/man8/tc-vlan.8      |  2 +-

Jiri, this *seriously* needs a proper documentation. I consider myself
to be well above average in understanding tc filters and actions, and as
you know I participated at least passively in some chats about the
chains. Yet I'm still very lost in semantics of chains. I cannot
imagine how an average user would be able to use this.

Some questions about the semantics:

- What chain(s) are processed by default? If I don't use goto_chain but
  have multiple chains, will only chain 0 be processed, or more? In
  what order, what are the rules? If I don't have a chain 0, what would
  happen?

- What is the relation between priorities and chains? I expected that
  chains are under the same priority but that's not the case in your
  example. For a user, it's very unclear why there are priorities and
  chains. They appear to do the same thing, why can't I just jump
  between priorities?

Please, in addition to explaining here on the list, add detailed
explanation to the man pages.

Thanks,

 Jiri
