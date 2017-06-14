From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] net_sched: move tcf_lock down after
 gen_replace_estimator()
Date: Wed, 14 Jun 2017 14:42:17 -0400 (EDT)
Message-ID: <20170614.144217.1489970097887149799.davem@davemloft.net>
References: <1497386184-14960-1-git-send-email-xiyou.wangcong@gmail.com>
        <20170613204040.GB3112@yuvallap>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, netdev@vger.kernel.org,
        nicholashuber@gmail.com, labbott@redhat.com, jhs@mojatatu.com
To: yuval.shaia@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52902 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751628AbdFNSmT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2017 14:42:19 -0400
In-Reply-To: <20170613204040.GB3112@yuvallap>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Shaia <yuval.shaia@oracle.com>
Date: Tue, 13 Jun 2017 23:40:41 +0300

> On Tue, Jun 13, 2017 at 01:36:24PM -0700, Cong Wang wrote:
>> Laura reported a sleep-in-atomic kernel warning inside
> 
> Since you added a Reported-by tag below i don't see a reason to
> specifically mention it in commit log message.

That doesn't make any sense at all.

Part of telling the story is saying that someone reported a specific
kind of issue, and here is the problem, and here is how we solved it.

Just because there's a reported-by tag doesn't mean it's superfluous.
