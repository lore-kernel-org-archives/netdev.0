From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v6_repost 2/3] net: core: add SW stats to
 if_stats_msg
Date: Tue, 23 Aug 2016 00:04:15 -0700 (PDT)
Message-ID: <20160823.000415.624700756560666111.davem@davemloft.net>
References: <1471612650-4508-3-git-send-email-jiri@resnulli.us>
        <57BBE47D.3060805@cumulusnetworks.com>
        <20160823065318.GA1975@nanopsycho>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com, netdev@vger.kernel.org,
        nogahf@mellanox.com, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, ogerlitz@mellanox.com,
        nikolay@cumulusnetworks.com, linville@tuxdriver.com, tgraf@suug.ch,
        gospo@cumulusnetworks.com, sfeldma@gmail.com, sd@queasysnail.net,
        eranbe@mellanox.com, ast@plumgrid.com, edumazet@google.com,
        hannes@stressinduktion.org, f.fainelli@gmail.com,
        dsa@cumulusnetworks.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48846 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751214AbcHWHEz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 03:04:55 -0400
In-Reply-To: <20160823065318.GA1975@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue, 23 Aug 2016 08:53:18 +0200

> Anyway I think that next level of nesting is not necessary. On
> contrary, it is wrong. The current level is extensible, mixed and
> flagged already. I don't see any reason why not to add whatever kind of
> stats here. What makes IFLA_STATS_LINK_SW_64 or for example
> IFLA_STATS_LINK_HW_ACL so special it has to be nested in some other
> attr? I would understand it it would be values of one family, but that
> is not the case.

First, I agree with Roopa.  If we want to put this stuff out
there is should be bucketed together in a nested attribute with
other similar stats specifications.

Second, the more I think about this what you're providing isn't
actually a new statistic type.

It's a filter.

So why don't we just provide a filter specification that gets passed
down into the driver.  And the user can ask for "SW stats" or whatever
using that.
