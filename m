From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] net sched actions: do not overwrite status of
 action creation.
Date: Sun, 26 Feb 2017 21:32:15 -0500 (EST)
Message-ID: <20170226.213215.1159999427558211898.davem@davemloft.net>
References: <1487975818-27254-1-git-send-email-mrv@mojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com
To: mrv@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33222 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751314AbdB0Cco (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 26 Feb 2017 21:32:44 -0500
In-Reply-To: <1487975818-27254-1-git-send-email-mrv@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roman Mashak <mrv@mojatatu.com>
Date: Fri, 24 Feb 2017 17:36:58 -0500

> nla_memdup_cookie was overwriting err value, declared at function
> scope and earlier initialized with result of ->init(). At success
> nla_memdup_cookie() returns 0, and thus module refcnt decremented,
> although the action was installed.
 ...
> Fixes: 1045ba77a ("net sched actions: Add support for user cookies")
> Signed-off-by: Roman Mashak <mrv@mojatatu.com>
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

Applied, thanks.
