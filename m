From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/6 net-next] cnic: Simplify netdev events handling.
Date: Mon, 29 Jul 2013 22:04:26 -0700 (PDT)
Message-ID: <20130729.220426.224154594518699860.davem@davemloft.net>
References: <1375063440-4016-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57192 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754498Ab3G3FE3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jul 2013 01:04:29 -0400
In-Reply-To: <1375063440-4016-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Sun, 28 Jul 2013 19:03:55 -0700

> After this earlier commit to simplify probing:
> 
>     commit 4bd9b0fffb193d2e288f67f81821af32df8d4349
>     cnic, bnx2x, bnx2: Simplify cnic probing.
> 
> we can now reliably receive netdev events and we can simplify the handling
> of these events.  We now remove the logic that tries to handle missed
> NETDEV_REGISTER events.
> 
> This change will allow cleanup to be simplified in the next patch.  We can
> now rely on the play back of netdev events during
> unregister_netdevice_notifier() to cleanup the structures.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Please, in the future, give me an introductory "[PATCH 0/6 ..." posting,
for two reasons:

1) So that you can give me a top-level description of the changes that
   are happening.

2) To provide me with a single email I can reply to when I decide that
   the entire series is OK.

I applied this entire series, thanks.

Thanks.
