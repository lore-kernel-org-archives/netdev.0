From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] geneve: add rtnl changelink support
Date: Mon, 08 May 2017 16:18:28 -0400 (EDT)
Message-ID: <20170508.161828.2205832008681371745.davem@davemloft.net>
References: <1494274104-16494-1-git-send-email-girish.moodalbail@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pshelar@ovn.org, joe@ovn.org,
        jbenc@redhat.com
To: girish.moodalbail@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38344 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756773AbdEHUSa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 8 May 2017 16:18:30 -0400
In-Reply-To: <1494274104-16494-1-git-send-email-girish.moodalbail@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Girish Moodalbail <girish.moodalbail@oracle.com>
Date: Mon,  8 May 2017 13:08:24 -0700

> This patch adds changelink rtnl operation support for geneve devices.
> Code changes involve:
>   - refactor geneve_newlink into geneve_nl2info to be used by both
>     geneve_newlink and geneve_changelink
>   - geneve_nl2info takes a changelink boolean argument to isolate
>     changelink checks and updates.
>   - Allow changing only a few attributes:
>     - return -EOPNOTSUPP for attributes that cannot be changed for
>       now. Incremental patches can make the non-supported one
>       available in the future if needed.
> 
> Signed-off-by: Girish Moodalbail <girish.moodalbail@oracle.com>

The net-next tree is closed, please resubmit this when the net-next
tree opens back up.

Thank you.
