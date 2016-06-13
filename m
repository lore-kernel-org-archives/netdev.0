From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 -next] sched: remove NET_XMIT_POLICED
Date: Sun, 12 Jun 2016 22:02:37 -0400 (EDT)
Message-ID: <20160612.220237.1542237134488036412.davem@davemloft.net>
References: <1465641964-12342-1-git-send-email-fw@strlen.de>
	<20160611.155407.1424553523659683009.davem@davemloft.net>
	<CAM_iQpWrpHscQUqnaSNZ=q1vhg=+k9zyaYLTRE4QRSxrtvK+iQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, netdev@vger.kernel.org
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54535 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933059AbcFMCCj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jun 2016 22:02:39 -0400
In-Reply-To: <CAM_iQpWrpHscQUqnaSNZ=q1vhg=+k9zyaYLTRE4QRSxrtvK+iQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Sat, 11 Jun 2016 17:14:09 -0700

> On Sat, Jun 11, 2016 at 3:54 PM, David Miller <davem@davemloft.net> wrote:
>> From: Florian Westphal <fw@strlen.de>
>> Date: Sat, 11 Jun 2016 12:46:04 +0200
>>
>>> sch_atm returns this when TC_ACT_SHOT classification occurs.
>>>
>>> But all other schedulers that use tc_classify
>>> (htb, hfsc, drr, fq_codel ...) return NET_XMIT_SUCCESS | __BYPASS
>>> in this case so just do that in atm.
>>
>> Yes, but it's been like this for two decades.
>>
>> One of the points of my reply to the previous version of this
>> patch is that indeed it is explicitly returned, intentionally.
> 
> I think this is a leftover from CONFIG_NET_CLS_POLICE removal.
> 
> BTW, probably TC_POLICE_* can be removed together.

Ok I'll apply this.
