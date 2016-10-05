From: David Miller <davem@davemloft.net>
Subject: Re: [patch net 0/2] mlxsw: Couple of fixes
Date: Tue, 04 Oct 2016 20:29:27 -0400 (EDT)
Message-ID: <20161004.202927.1650578832896717724.davem@davemloft.net>
References: <1475567165-3362-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yotamg@mellanox.com, idosch@mellanox.com,
        eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57582 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750940AbcJEA3b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Oct 2016 20:29:31 -0400
In-Reply-To: <1475567165-3362-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue,  4 Oct 2016 09:46:03 +0200

> Couple of fixes from Yotam.

Series applied, thanks.

Note that needed_headroom is a request, rather than a guarantee, so you
may in some rare cases need to realloc your headroom if the kernel was
not able to meet your request.
