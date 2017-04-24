From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v5 1/2] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Mon, 24 Apr 2017 16:30:33 -0400 (EDT)
Message-ID: <20170424.163033.797679814568299306.davem@davemloft.net>
References: <20170420142453.GF1886@nanopsycho.orion>
        <20170424091455.GA25218@vergenet.net>
        <2ca4266f-a164-d2ad-37fa-45f7ae354eb8@mojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: simon.horman@netronome.com, jiri@resnulli.us,
        xiyou.wangcong@gmail.com, eric.dumazet@gmail.com,
        netdev@vger.kernel.org, tom@herbertland.com, pablo@netfilter.org
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57386 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S977560AbdDXUah (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 16:30:37 -0400
In-Reply-To: <2ca4266f-a164-d2ad-37fa-45f7ae354eb8@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>
Date: Mon, 24 Apr 2017 08:49:00 -0400

> Yes, space is important and if i can express upto 32 flags
> with one TLV rather than 32 TLVs i choose one TLV.

Which is fine.  But two things:

1) Again, bits you aren't using now, make sure userspace doesn't
   set them.  And if it does, reject.

2) If you are worried about performance, we're talking about a TLV in
   the request here not the dump response itself so performance isn't
   a real issue as Pablo mentioned.
