From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rtnetlink: Handle IFLA_MASTER parameter when
 processing rtnl_newlink
Date: Wed, 01 Feb 2017 11:53:51 -0500 (EST)
Message-ID: <20170201.115351.83909828706888379.davem@davemloft.net>
References: <20170130232346.29761-1-theuns.verwoerd@alliedtelesis.co.nz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dsa@cumulusnetworks.com
To: theuns.verwoerd@alliedtelesis.co.nz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38918 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752960AbdBAQxw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 11:53:52 -0500
In-Reply-To: <20170130232346.29761-1-theuns.verwoerd@alliedtelesis.co.nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Theuns Verwoerd <theuns.verwoerd@alliedtelesis.co.nz>
Date: Tue, 31 Jan 2017 12:23:46 +1300

> Allow a master interface to be specified as one of the parameters when
> creating a new interface via rtnl_newlink.  Previously this would
> require invoking interface creation, waiting for it to complete, and
> then separately binding that new interface to a master.
> 
> In particular, this is used when creating a macvlan child interface for
> VRRP in a VRF configuration, allowing the interface creator to specify
> directly what master interface should be inherited by the child,
> without having to deal with asynchronous complications and potential
> race conditions.
> 
> Signed-off-by: Theuns Verwoerd <theuns.verwoerd@alliedtelesis.co.nz>

Applied to net-next, thanks.
