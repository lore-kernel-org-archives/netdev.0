From: David Miller <davem@davemloft.net>
Subject: Re: Case for reusing netlink PADs WAS(Re: [PATCH net-next 1/1] net
 sched actions: dump more than TCA_ACT_MAX_PRIO actions per batch
Date: Tue, 18 Apr 2017 11:29:35 -0400 (EDT)
Message-ID: <20170418.112935.686195434402345158.davem@davemloft.net>
References: <1492448905.10587.109.camel@edumazet-glaptop3.roam.corp.google.com>
        <560eeb0b-7a34-484a-e4a1-c637b31eba59@mojatatu.com>
        <20170418131656.GG1871@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, eric.dumazet@gmail.com, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40622 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757282AbdDRP3m (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 11:29:42 -0400
In-Reply-To: <20170418131656.GG1871@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue, 18 Apr 2017 15:16:56 +0200

> It's ugly. Plus user may pass garbage in pads from current apps.

%100 agreed.

> Why you don't just use new attributes? I don't get it.  I still
> don't understand why people feel need to do struct style message
> passing in TLV-designed Netlink interface...

Also agreed, I don't see why it's such a big deal.

Once we define a structure, let's set it in stone and don't try to
modify it's layout or meaning.  It is the only safe approach.

We made netlink have attributes exactly for this reason.
