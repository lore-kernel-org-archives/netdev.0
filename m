From: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
Subject: Re: [NET_NEXT PATCH 2/2] pkt_action: add new action skbedit
Date: Fri, 29 Aug 2008 22:47:16 -0700
Message-ID: <9929d2390808292247r116d26b2y9bf995d92d00d2d0@mail.gmail.com>
References: <20080828011253.7909.5172.stgit@jtkirshe-mobile.jf.intel.com>
	 <20080828011257.7909.78529.stgit@jtkirshe-mobile.jf.intel.com>
	 <20080829231345.d74f139d.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, davem@davemloft.net,
	"Alexander Duyck" <alexander.h.duyck@intel.com>
To: "Bill Fink" <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.173]:46955 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750876AbYH3FrS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Aug 2008 01:47:18 -0400
Received: by wf-out-1314.google.com with SMTP id 27so1069412wfd.4
        for <netdev@vger.kernel.org>; Fri, 29 Aug 2008 22:47:17 -0700 (PDT)
In-Reply-To: <20080829231345.d74f139d.billfink@mindspring.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 29, 2008 at 8:13 PM, Bill Fink <billfink@mindspring.com> wrote:
> On Wed, 27 Aug 2008, Jeff Kirsher wrote:
>
>> From: Alexander Duyck <alexander.h.duyck@intel.com>
>>
>> This new action will have the ability to change the priority and/or
>> queue_mapping fields on an sk_buff.
>>
>> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>> ---
>>
>>  include/linux/tc_act/tc_skbedit.h |   23 ++++
>>  include/net/tc_act/tc_skbedit.h   |   15 +++
>>  net/sched/Kconfig                 |   11 ++
>>  net/sched/Makefile                |    1
>>  net/sched/act_skbedit.c           |  199 +++++++++++++++++++++++++++++++++++++
>>  5 files changed, 249 insertions(+), 0 deletions(-)
>>  create mode 100644 include/linux/tc_act/tc_skbedit.h
>>  create mode 100644 include/net/tc_act/tc_skbedit.h
>>  create mode 100644 net/sched/act_skbedit.c
>
>> diff --git a/net/sched/Kconfig b/net/sched/Kconfig
>> index efaa7a7..613823b 100644
>> --- a/net/sched/Kconfig
>> +++ b/net/sched/Kconfig
>> @@ -485,6 +485,17 @@ config NET_ACT_SIMP
>>         To compile this code as a module, choose M here: the
>>         module will be called simple.
>>
>> +config NET_ACT_SKBEDIT
>> +        tristate "SKB Editing"
>> +        depends on NET_CLS_ACT
>> +        ---help---
>> +       Say Y here to change skb priority or queue_mapping settings.
>> +
>> +       If unsure, say N.
>> +
>> +       To compile this code as a module, choose M here: the
>> +       module will be called simple.
>> +
>>  config NET_CLS_IND
>>       bool "Incoming device classification"
>>       depends on NET_CLS_U32 || NET_CLS_FW
>
> I'm rather backlogged on e-mail at the moment, so apologies if someone
> else already pointed this out, but I'm guessing there was a copy and
> paste error here, as the module shouldn't be called simple (that's for
> the preceding NET_ACT_SIMP).
>
>                                                -Bill
>

Nice catch.  I was just about to post an updated patch set from Alex,
and it was a good thing I checked mail before sending the patches out.

I have corrected this in the next patch set (coming in about 10 minutes).

-- 
Cheers,
Jeff
