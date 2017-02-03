From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] bonding: Remove unnecessary returned value check
Date: Fri, 03 Feb 2017 16:25:30 -0500 (EST)
Message-ID: <20170203.162530.743465804005569199.davem@davemloft.net>
References: <1486097181-31568-1-git-send-email-yanjun.zhu@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: j.vosburgh@gmail.com, vfalico@gmail.com, andy@greyhouse.net,
        netdev@vger.kernel.org
To: yanjun.zhu@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53842 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752490AbdBCVZb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 16:25:31 -0500
In-Reply-To: <1486097181-31568-1-git-send-email-yanjun.zhu@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhu Yanjun <yanjun.zhu@oracle.com>
Date: Thu,  2 Feb 2017 23:46:21 -0500

> The function bond_info_query alwarys returns 0. As such, in the function
> bond_do_ioctl, it is not necessary to check the returned value. So the
> interface type of the function bond_info_query is changed to void. The
> redundant check is removed.
> 
> Signed-off-by: Zhu Yanjun <yanjun.zhu@oracle.com>

Applied to net-next, thanks.
