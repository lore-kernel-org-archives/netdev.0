From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] VXLAN/geneve RCU fixes
Date: Wed, 01 Mar 2017 12:59:26 -0500 (EST)
Message-ID: <20170301.125926.1968388840285393194.davem@davemloft.net>
References: <20170224194337.67538-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com, kubakici@wp.pl,
        xiyou.wangcong@gmail.com, pshelar@ovn.org, jbenc@redhat.com,
        linville@tuxdriver.com
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49230 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751917AbdCAR72 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Mar 2017 12:59:28 -0500
In-Reply-To: <20170224194337.67538-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Fri, 24 Feb 2017 11:43:35 -0800

> VXLAN and GENEVE need to take RCU lock explicitly because TX path
> only has the _bh() flavour of RCU locked.  Making the reconfiguration
> path wait for both normal and _bh() RCU would be bigger hassle so
> just acquire the lock, as suggested by Pravin:
> 
> https://www.mail-archive.com/netdev@vger.kernel.org/msg155583.html

Series applied and queued up for -stable, thanks.
