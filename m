From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] net: sched: cls_flower: fix ndo_setup_tc type
 for stats call
Date: Wed, 16 Aug 2017 14:30:07 -0700 (PDT)
Message-ID: <20170816.143007.1921520243729810520.davem@davemloft.net>
References: <20170816151518.4554-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        mlxsw@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38738 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752154AbdHPVaI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 17:30:08 -0400
In-Reply-To: <20170816151518.4554-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Wed, 16 Aug 2017 17:15:18 +0200

> From: Jiri Pirko <jiri@mellanox.com>
> 
> I made a stupid mistake using TC_CLSFLOWER_STATS instead of
> TC_SETUP_CLSFLOWER. Funny thing is that both are defined as "2" so it
> actually did not cause any harm. Anyway, fixing it now.
> 
> Fixes: 2572ac53c46f ("net: sched: make type an argument for ndo_setup_tc")
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Applied, thanks Jiri.
