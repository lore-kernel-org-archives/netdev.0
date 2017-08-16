From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net_sched: call qlen_notify only if child qdisc is
 empty
Date: Wed, 16 Aug 2017 10:56:57 -0700 (PDT)
Message-ID: <20170816.105657.1279204691313415545.davem@davemloft.net>
References: <150280439968.717891.6476652519937001709.stgit@buzz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com, jkosina@suse.cz,
        edumazet@google.com, jhs@mojatatu.com
To: khlebnikov@yandex-team.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34296 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752229AbdHPR46 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 13:56:58 -0400
In-Reply-To: <150280439968.717891.6476652519937001709.stgit@buzz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Date: Tue, 15 Aug 2017 16:39:59 +0300

> This callback is used for deactivating class in parent qdisc.
> This is cheaper to test queue length right here.
> 
> Also this allows to catch draining screwed backlog and prevent
> second deactivation of already inactive parent class which will
> crash kernel for sure. Kernel with print warning at destruction
> of child qdisc where no packets but backlog is not zero.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

Applied.
