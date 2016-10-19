From: David Miller <davem@davemloft.net>
Subject: Re: [patch net] rtnetlink: Add rtnexthop offload flag to compare
 mask
Date: Wed, 19 Oct 2016 11:08:23 -0400 (EDT)
Message-ID: <20161019.110823.542236554316461605.davem@davemloft.net>
References: <1476809974-14707-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
        roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        linville@tuxdriver.com, andy@greyhouse.net, f.fainelli@gmail.com,
        dsa@cumulusnetworks.com, jhs@mojatatu.com,
        vivien.didelot@savoirfairelinux.com, andrew@lunn.ch,
        ivecera@redhat.com, nicolas.dichtel@6wind.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56468 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S942678AbcJSPI0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2016 11:08:26 -0400
In-Reply-To: <1476809974-14707-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue, 18 Oct 2016 18:59:34 +0200

> From: Jiri Pirko <jiri@mellanox.com>
> 
> The offload flag is a status flag and should not be used by
> FIB semantics for comparison.
> 
> Fixes: 37ed9493699c ("rtnetlink: add RTNH_F_EXTERNAL flag for fib offload")
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Ouch, good catch.

Applied and queued up for -stable, thanks!
