From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Use ns_capable_noaudit() when determining net
 sysctl permissions
Date: Sat, 01 Oct 2016 03:25:04 -0400 (EDT)
Message-ID: <20161001.032504.1254372735513201320.davem@davemloft.net>
References: <20160930222431.GA30208@dtor-ws>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tyhicks@canonical.com, serge.hallyn@ubuntu.com,
        james.l.morris@oracle.com, ebiederm@xmission.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: dmitry.torokhov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51994 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750845AbcJAHZR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 1 Oct 2016 03:25:17 -0400
In-Reply-To: <20160930222431.GA30208@dtor-ws>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Date: Fri, 30 Sep 2016 15:24:31 -0700

> From: Tyler Hicks <tyhicks@canonical.com>
> 
> The capability check should not be audited since it is only being used
> to determine the inode permissions. A failed check does not indicate a
> violation of security policy but, when an LSM is enabled, a denial audit
> message was being generated.
> 
> The denial audit message caused confusion for some application authors
> because root-running Go applications always triggered the denial. To
> prevent this confusion, the capability check in net_ctl_permissions() is
> switched to the noaudit variant.
> 
> BugLink: https://launchpad.net/bugs/1465724
> 
> Signed-off-by: Tyler Hicks <tyhicks@canonical.com>
> Acked-by: Serge E. Hallyn <serge.hallyn@ubuntu.com>
> Signed-off-by: James Morris <james.l.morris@oracle.com>
> [dtor: reapplied after e79c6a4fc923 ("net: make net namespace sysctls
> belong to container's owner") accidentally reverted the change.]
> Signed-off-by: Dmitry Torokhov <dmitry.torokhov@gmail.com>

Applied, but please be clear in the future what tree a patch
is targetting, in this case 'net-next'.

You can indicate this in the Subject line "[PATCH net-next]".
