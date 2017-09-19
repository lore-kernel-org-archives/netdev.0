From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 03/14] gtp: Call common functions to get
 tunnel routes and add dst_cache
Date: Tue, 19 Sep 2017 10:44:46 -0700 (PDT)
Message-ID: <20170919.104446.1562100139136479510.davem@davemloft.net>
References: <20170919003904.5124-4-tom@quantonium.net>
        <20170918.211751.1871429944584121281.davem@davemloft.net>
        <20170919120942.dpy5kmkhzws7pqd5@nataraja>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom@quantonium.net, netdev@vger.kernel.org, pablo@netfilter.org,
        rohit@quantonium.net
To: laforge@gnumonks.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37378 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750973AbdISRos (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 13:44:48 -0400
In-Reply-To: <20170919120942.dpy5kmkhzws7pqd5@nataraja>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harald Welte <laforge@gnumonks.org>
Date: Tue, 19 Sep 2017 20:09:42 +0800

> So I guess you're asking us to document that rationale as form of a
> source code comment ?

Yes that would make ignoring the potential changing of the non-const
'saddr' argument at least be documented.
